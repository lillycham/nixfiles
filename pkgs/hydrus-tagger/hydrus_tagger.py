"""Import memes into hydrus with machine tags.

For each new image, GIF or video in the given folders, this:

- imports the file through the hydrus Client API (hydrus copies it in),
- tags it with the WD tagger (general, character and rating tags),
- reads its text with Apple's Vision framework and adds a caption: tag and
  an "ocr" note,
- adds the file name as a filename: tag.

Machine tags go to the "ai tags" service and the filename: tag to "my tags".
Processed files are remembered by hash, so each file is handled once.
"""

import argparse
import csv
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

import numpy as np
import onnxruntime as ort
from PIL import Image

MODEL_DIR = Path(os.environ["HYDRUS_TAGGER_MODEL"])
MEDIA_TOOL = os.environ["HYDRUS_TAGGER_MEDIA"]
API = "http://127.0.0.1:45869"
KEY_FILE = Path.home() / ".config/hydrus-tagger/api-key"
STATE_FILE = Path.home() / "Library/Application Support/hydrus-tagger/done"

EXTENSIONS = {".png", ".jpg", ".jpeg", ".jfif", ".webp", ".gif", ".bmp", ".avif", ".heic",
              ".mp4", ".mov", ".webm", ".mkv", ".m4v"}

GENERAL_THRESHOLD = 0.35
CHARACTER_THRESHOLD = 0.85

# WD tag names use underscores for spaces, except in these kaomoji.
KAOMOJI = {"0_0", "(o)_(o)", "+_+", "+_-", "._.", "<o>_<o>", "<|>_<|>", "=_=", ">_<",
           "3_3", "6_9", ">_o", "@_@", "^_^", "o_o", "u_u", "x_x", "|_|", "||_||"}

# OCR lines that are social media chrome or watermarks, not caption text.
JUNK_LINE = re.compile(
    r"^(@\w+|https?://\S+|\S+\.(com|net|org|gg|co)\b.*|[\d\s:.,/%KkMm·-]+|"
    r"reply|repost|retweets?|likes?|quotes?|views?|bookmarks?|follow(ing)?|translate post|"
    r"show more|imgflip.*|ifunny.*|made with.*|tiktok.*|reddit.*)$",
    re.IGNORECASE,
)


class Hydrus:
    def __init__(self, key):
        self.key = key

    def call(self, path, body=None):
        req = urllib.request.Request(
            API + path,
            data=None if body is None else json.dumps(body).encode(),
            headers={"Hydrus-Client-API-Access-Key": self.key,
                     "Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=60) as resp:
            body = resp.read()
        # Some calls, such as add_tags, reply with an empty body.
        return json.loads(body) if body else None

    def tag_service(self, name):
        services = self.call("/get_services")
        if isinstance(services.get("services"), dict):
            for key, info in services["services"].items():
                if info.get("name") == name:
                    return key
        for group in services.values():
            if isinstance(group, list):
                for info in group:
                    if info.get("name") == name:
                        return info["service_key"]
        sys.exit(f'hydrus has no tag service called "{name}"')


class Tagger:
    def __init__(self):
        self.session = ort.InferenceSession(str(MODEL_DIR / "model.onnx"),
                                            providers=["CPUExecutionProvider"])
        self.input = self.session.get_inputs()[0]
        self.size = self.input.shape[1]
        with open(MODEL_DIR / "selected_tags.csv", newline="") as f:
            rows = list(csv.DictReader(f))
        self.names = [r["name"] if r["name"] in KAOMOJI else r["name"].replace("_", " ")
                      for r in rows]
        self.categories = np.array([int(r["category"]) for r in rows])

    def prepare(self, path):
        image = Image.open(path)
        canvas = Image.new("RGBA", image.size, (255, 255, 255, 255))
        canvas.alpha_composite(image.convert("RGBA"))
        image = canvas.convert("RGB")
        side = max(image.size)
        square = Image.new("RGB", (side, side), (255, 255, 255))
        square.paste(image, ((side - image.width) // 2, (side - image.height) // 2))
        square = square.resize((self.size, self.size), Image.BICUBIC)
        return np.asarray(square, dtype=np.float32)[:, :, ::-1]  # RGB to BGR

    def tags(self, frames):
        batch = np.stack([self.prepare(f) for f in frames])
        output = self.session.run(None, {self.input.name: batch})[0]
        probs = output.max(axis=0)  # a tag counts if any frame shows it
        tags = []
        for i in np.flatnonzero((self.categories == 0) & (probs >= GENERAL_THRESHOLD)):
            tags.append(self.names[i])
        for i in np.flatnonzero((self.categories == 4) & (probs >= CHARACTER_THRESHOLD)):
            tags.append("character:" + self.names[i])
        ratings = np.flatnonzero(self.categories == 9)
        if len(ratings):
            tags.append("rating:" + self.names[ratings[probs[ratings].argmax()]])
        return tags


def ffmpeg_media(path, tmp):
    """Fallback for videos that AVFoundation can't decode, such as WebM."""
    try:
        duration = float(subprocess.check_output(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "csv=p=0", str(path)], text=True).strip())
    except (subprocess.CalledProcessError, ValueError):
        return {"frames": [], "lines": []}
    frames, best = [], []
    for i in range(5):
        frame = Path(tmp, f"ff{i}.png")
        subprocess.run(["ffmpeg", "-v", "fatal", "-ss", str(duration * (i + 0.5) / 5),
                        "-i", str(path), "-frames:v", "1", "-y", str(frame)])
        if not frame.exists():
            continue
        frames.append(str(frame))
        lines = json.loads(subprocess.check_output([MEDIA_TOOL, str(frame), tmp]))["lines"]
        if len("".join(t for t, _ in lines)) > len("".join(t for t, _ in best)):
            best = lines
    return {"frames": frames, "lines": best}


def caption(lines):
    text = " ".join(t for t, c in lines if c >= 0.5 and not JUNK_LINE.match(t.strip()))
    text = re.sub(r"\s+", " ", text).strip()
    return text[:200].rsplit(" ", 1)[0] if len(text) > 200 else text


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("folders", nargs="+", type=Path)
    parser.add_argument("--ai-tags", default="ai tags", help="tag service for machine tags")
    parser.add_argument("--my-tags", default="my tags", help="tag service for filename: tags")
    parser.add_argument("--dry-run", action="store_true", help="print tags, change nothing")
    args = parser.parse_args()

    done = set(STATE_FILE.read_text().split()) if STATE_FILE.exists() else set()
    todo = []
    for folder in args.folders:
        for path in sorted(folder.expanduser().iterdir()):
            if path.is_file() and not path.name.startswith(".") and path.suffix.lower() in EXTENSIONS:
                digest = sha256(path)
                if digest not in done:
                    todo.append((path, digest))
    if not todo:
        return

    hydrus = None
    if not args.dry_run:
        if not KEY_FILE.exists():
            sys.exit(f"no API key: save one to {KEY_FILE}")
        hydrus = Hydrus(KEY_FILE.read_text().strip())
        try:
            ai_key = hydrus.tag_service(args.ai_tags)
            my_key = hydrus.tag_service(args.my_tags)
        except urllib.error.URLError:
            print("hydrus isn't running; will try again later")
            return

    tagger = Tagger()
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    for path, digest in todo:
        with tempfile.TemporaryDirectory() as tmp:
            media = json.loads(subprocess.check_output([MEDIA_TOOL, str(path), tmp]))
            if not media["frames"]:
                media = ffmpeg_media(path, tmp)
            if not media["frames"]:
                print(f"skipped, can't read: {path}")
                continue
            tags = tagger.tags(media["frames"])
        text = caption(media["lines"])
        if text:
            tags.append("caption:" + text)
        note = "\n".join(t for t, c in media["lines"] if c >= 0.3)

        if args.dry_run:
            print(f"{path.name}: {len(tags)} tags, {len(note)} chars of text")
            continue

        try:
            result = hydrus.call("/add_files/add_file", {"path": str(path.resolve())})
        except urllib.error.URLError:
            print("lost contact with hydrus; will try again later")
            return
        status = result["status"]
        if status in (3, 7):  # deleted before, or vetoed by import options
            print(f"hydrus refused ({result.get('note', status)}): {path.name}")
        elif status in (1, 2):
            hydrus.call("/add_tags/add_tags", {
                "hash": result["hash"],
                "service_keys_to_tags": {ai_key: tags, my_key: ["filename:" + path.stem]},
            })
            if note:
                hydrus.call("/add_notes/set_notes", {"hash": result["hash"], "notes": {"ocr": note}})
            print(f"imported with {len(tags)} tags: {path.name}")
        else:
            print(f"import failed ({result.get('note', status)}): {path.name}")
            continue
        with STATE_FILE.open("a") as f:
            f.write(digest + "\n")


if __name__ == "__main__":
    main()
