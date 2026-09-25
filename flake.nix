{
  description = "Nix system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Emacs and its packages are built from this nixpkgs, not the main one.
    # nixpkgs doesn't cache emacs packages, so updating it rebuilds them all.
    # Update it on purpose with `nix flake update nixpkgs-emacs`.
    nixpkgs-emacs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nur.url = "github:nix-community/nur";

    # My NUR repository, used directly until nix-community/NUR#1235 is merged.
    # After that, use pkgs.nur.repos.lillycham and remove this input.
    lillycham-nur = {
      url = "github:lillycham/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, nur, ... }:
    # Output for MacBook, hostname 'mirai'
    let
      mirai = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.lcham =
              homeManagerConfFor ./hosts/mirai/home.nix;
          }
          ./hosts/mirai/default.nix
        ];
      };
      # Output for NixOS PC
      ikigai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/ikigai/configuration.nix
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.lcham =
              homeManagerConfFor ./hosts/ikigai/home.nix;
          }
        ];
      };
      # Call a home manager config with overlays
      homeManagerConfFor = config:
        { ... }: {
          nixpkgs.overlays = [
            nur.overlays.default
            (final: prev: {
              inherit (inputs.lillycham-nur.legacyPackages.${prev.stdenv.hostPlatform.system}) hydrus-tagger;
            })
            (import ./overlays)
          ];
          imports = [ config ];
        };
    in
    {
      darwinConfigurations.mirai = mirai;
      packages.aarch64-darwin.default = mirai.system;
      nixosConfigurations."ikigai" = ikigai;
    };
}
