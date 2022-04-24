function nix-install
	nix-env -iA nixpkgs.$argv
end