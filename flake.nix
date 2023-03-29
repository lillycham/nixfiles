{
  description = "Nix system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nur.url = "github:nix-community/nur";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-src = {
      url = "github:emacs-mirror/emacs/emacs-29";
      flake = false;
    };

    nixpkgs-tny = {
      url = "github:tnytown/nixpkgs-overlay-tny";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, nur, emacs-overlay, emacs-src, nixpkgs-tny }:
    # Output for MacBook, hostname 'mirai'
    let mirai = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            {
              home-manager.users.lillycham =
                homeManagerConfFor ./hosts/mirai/home.nix;
            }
            ./hosts/mirai/default.nix
          ];
          inputs = { inherit darwin home-manager nixpkgs emacs-overlay; };
        };
        # Output for NixOS PC
        ikigai = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/ikigai/default.nix
            {
              home-manager.users.lillycham =
                homeManagerConfFor ./hosts/ikigai/home.nix;
            }
          ];
        };
        oracle = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          modules = [
            {
              home-manager.users.opc =
                homeManagerConfFor ./hosts/oracle-arm/home.nix;
            }
          ];
        };
        # Call a home manager config with overlays
        homeManagerConfFor = config:
          { ... }: {
            nixpkgs.overlays = [
              nur.overlay
              (_: _: {
                emacsMacport = nixpkgs-tny.packages."aarch64-darwin".emacsMacport;
              })
              emacs-overlay.overlay
              (final: prev: {
                emacs29-pgtk = prev.emacsGit.overrideAttrs(old: {
                  name = "emacs-pgtk";
                  version = emacs-src.shortRev;
                  src = emacs-src;
                  withPgtk = true;
                });
                emacs29 = prev.emacsGit.overrideAttrs(old: {
                  name = "emacs";
                  version = emacs-src.shortRev;
                  src = emacs-src;
                });
              })
              emacs-overlay.overlay
            ];
            imports = [ config ];
          };
    in
    {
      darwinConfigurations.mirai = mirai;
      defaultPackage.aarch64-darwin = mirai.system;
      homeConfigurations.oracle = oracle;
      defaultPackage.aarch64-linux = oracle.activationPackage;
    };
}
