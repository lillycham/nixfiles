// hydrus-tagger-media FILE OUTDIR
//
// Saves up to five frames of an image, GIF or video to OUTDIR as PNGs, and
// reads the text on them with Apple's Vision framework. Prints JSON:
// {"frames": [png paths], "lines": [[text, confidence], ...]}, where
// "lines" comes from the frame with the most text.
import AVFoundation
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

let maxFrames = 5

func recognise(_ image: CGImage) -> [(String, Float)] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.automaticallyDetectsLanguage = true
    try? VNImageRequestHandler(cgImage: image).perform([request])
    let observations = (request.results ?? []).sorted {
        // Top to bottom, then left to right. Vision's origin is bottom left.
        abs($0.boundingBox.midY - $1.boundingBox.midY) > 0.02
            ? $0.boundingBox.midY > $1.boundingBox.midY
            : $0.boundingBox.minX < $1.boundingBox.minX
    }
    return observations.compactMap { obs in
        obs.topCandidates(1).first.map { ($0.string, $0.confidence) }
    }
}

// Evenly spaced positions in 0..<1, away from the very start and end.
func positions(_ n: Int) -> [Double] {
    (0..<n).map { (Double($0) + 0.5) / Double(n) }
}

func frames(of url: URL) async -> [CGImage] {
    let videoTypes: Set = ["mp4", "mov", "webm", "mkv", "m4v"]
    if videoTypes.contains(url.pathExtension.lowercased()) {
        let asset = AVURLAsset(url: url)
        guard let duration = try? await asset.load(.duration), duration.seconds > 0 else { return [] }
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        var images: [CGImage] = []
        for p in positions(maxFrames) {
            let time = CMTime(seconds: duration.seconds * p, preferredTimescale: 600)
            if let (image, _) = try? await generator.image(at: time) { images.append(image) }
        }
        return images
    }
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return [] }
    let count = CGImageSourceGetCount(source)
    let indices = count <= 1 ? [0] : Array(Set(positions(min(count, maxFrames)).map { Int($0 * Double(count)) })).sorted()
    return indices.compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }
}

func writePNG(_ image: CGImage, to url: URL) -> Bool {
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return false }
    CGImageDestinationAddImage(dest, image, nil)
    return CGImageDestinationFinalize(dest)
}

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write("usage: hydrus-tagger-media FILE OUTDIR\n".data(using: .utf8)!)
    exit(2)
}
let outDir = URL(fileURLWithPath: args[2])
let images = await frames(of: URL(fileURLWithPath: args[1]))
var paths: [String] = []
for (i, image) in images.enumerated() {
    let url = outDir.appendingPathComponent("frame\(i).png")
    if writePNG(image, to: url) { paths.append(url.path) }
}
let best = images.map(recognise).max { $0.map(\.0).joined().count < $1.map(\.0).joined().count } ?? []
let record: [String: Any] = ["frames": paths, "lines": best.map { [$0.0, $0.1] }]
print(String(data: try! JSONSerialization.data(withJSONObject: record), encoding: .utf8)!)
