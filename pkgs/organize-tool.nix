{ lib, python3Packages, fetchPypi }:
let
  simplematch = python3Packages.buildPythonPackage rec {
    pname = "simplematch";
    version = "1.4";
    format = "wheel";
    src = fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      hash = "sha256-57iY4XS8EcO93Bse42qdcN2WA3KVg3qHkZUFLJIQcjc=";
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "organize-tool";
  version = "3.3.0";
  format = "wheel";

  src = fetchPypi {
    pname = "organize_tool";
    inherit version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-nxvgz4n2UKGO3+NlFYbl4ebfmBE3M0hY/pBbHbVtSS8=";
  };

  dependencies = with python3Packages; [
    arrow
    docopt-ng
    docx2txt
    exifread
    jinja2
    natsort
    pdfminer-six
    platformdirs
    pydantic
    pyyaml
    rich
    send2trash
    simplematch
  ];

  # nixpkgs has newer versions than upstream pins. macos-tags isn't in nixpkgs;
  # organize only imports it for the macos_tags filter and action.
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "macos-tags" ];

  pythonImportsCheck = [ "organize" ];

  meta = {
    description = "The file management automation tool";
    homepage = "https://github.com/tfeldmann/organize";
    license = lib.licenses.mit;
    mainProgram = "organize";
  };
}
