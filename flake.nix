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
  };

  outputs = { self, nixpkgs, home-manager, darwin, nur, emacs-overlay, emacs-src}:
    let #mirai = 
        ikigai = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/ikigai/default.nix
          ];
        };
        homeManagerConfFor = config:
          { ... }: {
            nixpkgs.overlays = [
              nur.overlay
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
            ];
            imports = [ config ];
          };
    in
    {
      # Output for MacBook, hostname 'mirai'
      darwinConfigurations = {
        mirai = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            {
              home-manager.users.lillycham =
                homeManagerConfFor ./hosts/mirai/home.nix;
            }
            ./hosts/mirai/default.nix
          ];
          inputs = { inherit darwin home-manager nixpkgs; };
        };
      };
  };
}
