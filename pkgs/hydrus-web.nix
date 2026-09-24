{ lib, buildNpmPackage, fetchFromGitHub }:
buildNpmPackage rec {
  pname = "hydrus-web";
  version = "1.3.0-unstable-2025-11-06";

  # The last release (v1.3.0) is from 2024. The dev branch has fixes for
  # newer hydrus versions and for Chrome's local network access prompt.
  src = fetchFromGitHub {
    owner = "floogulinc";
    repo = "hydrus-web";
    rev = "c9359cb8ce8e2b8e84d931b634a95706de3a7d85";
    hash = "sha256-pQ/dz0jZPGeofB/3+eye+BBr3M4q4f+uE4AuAp9IFPg=";
  };

  npmDepsHash = "sha256-f1Qb8KsnLJXN3wkV+kFGwiUaLo1Wnxury/H/by3TMFw=";

  # Skip native addons. The only one, nice-napi, is an optional speed-up for
  # the build tools and doesn't compile with current clang.
  npmRebuildFlags = [ "--ignore-scripts" ];

  # version-info.js reads the commit from git, unless it runs on GitHub
  # Actions. There is no .git in the build, so pretend.
  env = {
    GITHUB_ACTIONS = "true";
    GITHUB_REF_NAME = "dev";
    GITHUB_SHA = src.rev;
  };

  installPhase = ''
    runHook preInstall
    cp -r dist/hydrus-web $out
    runHook postInstall
  '';

  meta = {
    description = "A web client for hydrus network";
    homepage = "https://github.com/floogulinc/hydrus-web";
    license = lib.licenses.mit;
  };
}
