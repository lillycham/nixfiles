{ lib, stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation rec {
  pname = "omp";
  version = "18.10.4";

  # The release binary is a Bun executable, signed by upstream. Building from
  # source needs 2000+ derivations (Rust, Zig and Bun), so use the binary.
  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
    hash = "sha256-dFkzN2DvDiZdXUBEXqRZ2j0YoQ7z7ElYMC4Zd7Usiis=";
  };

  dontUnpack = true;

  # Bun appends the program to the executable. Strip or patch would corrupt it.
  dontStrip = true;
  dontPatchELF = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  meta = {
    description = "Coding agent with the IDE wired in";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
