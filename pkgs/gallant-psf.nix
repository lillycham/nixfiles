# Gallant, the 12x22 console font of Sun's SPARCstations, as a Linux console
# font. A console font holds 512 glyphs at most, so it keeps Latin, box
# drawing and the usual symbols.
#
# doubled = true gives 24x44. The kernel can show that, but
# systemd-vconsole-setup can't read back a font taller than 32 px, so the
# font is lost when the display driver takes over from the boot framebuffer.
{ lib, stdenvNoCC, fetchFromGitHub, bdf2psf, python3, doubled ? false }:

let
  name = if doubled then "gallant-24x44" else "gallant-12x22";
in
stdenvNoCC.mkDerivation {
  pname = "gallant-psf";
  version = "0.1-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "NanoBillion";
    repo = "gallant";
    rev = "ed9de4dfe047322d181618ed68a485ce8fa153e3";
    hash = "sha256-TGhT1NzSfDQPFCEySRGwINnKCPCbapMnVc3JitfX08w=";
  };

  nativeBuildInputs = [ bdf2psf python3 ];

  # Double every pixel of the BDF: each bit of a row becomes two bits, each
  # row is written twice, and every size and offset doubles.
  doubleBdf = ''
    import sys

    def doubled(fields):
        return " ".join(str(int(f) * 2) for f in fields)

    width = 0
    in_bitmap = False
    for line in sys.stdin:
        line = line.rstrip("\n")
        key, _, rest = line.partition(" ")
        if in_bitmap and key != "ENDCHAR":
            bits = bin(int(line, 16))[2:].zfill(len(line) * 4)[:width]
            wide = "".join(b * 2 for b in bits)
            wide += "0" * (-len(wide) % 8)
            row = format(int(wide, 2), "0%dX" % (len(wide) // 4))
            print(row)
            print(row)
            continue
        in_bitmap = False
        if key in ("SIZE",):
            size, *res = rest.split()
            print(key, int(size) * 2, *res)
        elif key in ("FONTBOUNDINGBOX", "BBX"):
            width = int(rest.split()[0])
            print(key, doubled(rest.split()))
        elif key == "DWIDTH":
            print(key, doubled(rest.split()))
        elif key in ("PIXEL_SIZE", "POINT_SIZE", "AVERAGE_WIDTH",
                     "FONT_ASCENT", "FONT_DESCENT"):
            print(key, int(rest) * 2)
        elif key == "FONT":
            # bdf2psf reads the width from the name too. These XLFD fields
            # are the pixel size, point size and average width.
            xlfd = rest.split("-")
            for i in (7, 8, 12):
                xlfd[i] = str(int(xlfd[i]) * 2)
            print(key, "-".join(xlfd))
        elif key == "BITMAP":
            in_bitmap = True
            print(line)
        else:
            print(line)
  '';

  passAsFile = [ "doubleBdf" ];

  buildPhase = ''
    runHook preBuild
    ${if doubled
      then ''python3 "$doubleBdfPath" < gallant.bdf > ${name}.bdf''
      else "cp gallant.bdf ${name}.bdf"}
    data=${bdf2psf}/share/bdf2psf
    bdf2psf --fb ${name}.bdf $data/standard.equivalents \
      $data/ascii.set+$data/linux.set+$data/useful.set 512 ${name}.psf
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 ${name}.psf $out/share/consolefonts/${name}.psf
    runHook postInstall
  '';

  passthru.fontFile = "share/consolefonts/${name}.psf";

  meta = {
    description = "Sun's Gallant console font from the SPARCstation";
    homepage = "https://github.com/NanoBillion/gallant";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
  };
}
