{
  description = "Nix system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # hydrus doesn't build on macOS 15 from nixpkgs of 2026-11: mpv needs a
    # Swift runtime symbol (_swift_coroFrameAlloc) that macOS 15 lacks, and
    # pyqt6 fails its import check (Hydra can't build it either). So mirai
    # takes hydrus from the last nixpkgs that worked. Drop this once mirai is
    # on macOS 26 and nixpkgs builds hydrus again.
    nixpkgs-hydrus.url = "github:nixos/nixpkgs/00455b0a3690d3f5dc61e9aef4277dc86235b73f";

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

    # The module, service helpers and dashboard fonts still come from upstream.
    # The normal CLI comes from NUR; this input also supports local dev builds.
    akyuu = {
      url = "github:lillycham/akyuu";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative multi-harness skill graph compiler and Home Manager module.
    skillx = {
      url = "github:lillycham/skillx";
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
      # Output for the M1 MacBook Air in macOS, hostname 'omoide-mac'.
      # The same machine boots NixOS as 'omoide'.
      omoide-mac = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.lcham =
              homeManagerConfFor ./hosts/omoide-mac/home.nix;
          }
          ./hosts/omoide-mac/default.nix
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
            # See the nixpkgs-hydrus input. Only macOS is affected. The pinned
            # set gets the same overlay, which hydrus needs on macOS.
            (final: prev: prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
              inherit (import inputs.nixpkgs-hydrus {
                inherit (prev.stdenv.hostPlatform) system;
                overlays = [ (import ./overlays) ];
              }) hydrus;
            })
            (import ./overlays)
          ];
          imports = [ config ];
        };
    in
    {
      darwinConfigurations.mirai = mirai;
      darwinConfigurations.mirai-akyuu-dev = mirai.extendModules {
        modules = [{
          home-manager.users.lcham.programs.akyuu.package =
            nixpkgs.lib.mkForce inputs.akyuu.packages.aarch64-darwin.default;
        }];
      };
      darwinConfigurations.omoide-mac = omoide-mac;
      packages.aarch64-darwin.default = mirai.system;
      nixosConfigurations."ikigai" = ikigai;
      nixosConfigurations."omoide" = omoide;
    };
}
