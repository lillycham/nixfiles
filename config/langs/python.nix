{ config, pkgs, ...}:
let python =
      (pkgs.python3.withPackages (p: with p; [
        flask
        matplotlib
        numpy
        pandas
        pygame
        tensorflow
        requests
        scipy
        torch
        sentencepiece
        z3
        ipykernel
        keras
      ]));
    jupyterWithBatteries = pkgs.jupyter.override {
      definitions = {
        python3 = let env = python;
        in {
          displayName = "Python 3";
          argv = [
            "${env.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          language = "python";
          logo32 = "${env.sitePackages}/ipykernel/resources/logo-32x32.png";
          logo64 = "${env.sitePackages}/ipykernel/resources/logo-64x64.png";
        };
      };
    };
    in
{
  home.packages = [ python jupyterWithBatteries ];
}
