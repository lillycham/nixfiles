final: prev: {
  organize-tool = final.callPackage ../pkgs/organize-tool.nix { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      # The tests need Xvfb, which is Linux-only. hydrus depends on this.
      mpv = pyprev.mpv.overridePythonAttrs (old: {
        doCheck = !prev.stdenv.hostPlatform.isDarwin;
      });
    })
  ];
}
