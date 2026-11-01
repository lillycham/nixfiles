{
  description = "Nix system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Emacs and its packages are built from this nixpkgs, not the main one.
    # nixpkgs doesn't cache emacs packages, so updating it rebuilds them all.
    # Update it on purpose with `nix flake update nixpkgs-emacs`.
    nixpkgs-emacs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nur.url = "github:nix-community/nur";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    # Apple Silicon support for omoide. Pinned to a release, because there is no
    # binary cache and a new kernel builds from source on the laptop.
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/release-2026-07-30";

    # omoide uses the nixpkgs that nixos-apple-silicon is locked to, so a normal
    # update of nixpkgs does not rebuild its kernel.
    nixpkgs-asahi.follows = "nixos-apple-silicon/nixpkgs";

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

    # My local-model harness. Taken as a flake, not from NUR, for its
    # home-manager module. Tracks the dev branch, ahead of releases.
    nibble = {
      url = "github:lillycham/nibble/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My memory store for agents. The repository is private, so this is a git
    # URL: nix then fetches it with git, which uses my GitHub credentials. The
    # `github:` form would need an access token in nix.conf.
    akyuu = {
      url = "git+https://github.com/lillycham/akyuu";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The probes behind the dashboard (config/dashboard).
    shiki = {
      url = "github:lillycham/shiki";
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
      # Output for M1 MacBook Air (Asahi)
      omoide = inputs.nixpkgs-asahi.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
          home-manager.nixosModules.home-manager
          ./hosts/omoide/configuration.nix
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.lcham =
              homeManagerConfFor ./hosts/omoide/home.nix;
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
      nixosConfigurations."omoide" = omoide;
    };
}
