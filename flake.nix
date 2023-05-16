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
  };

  outputs = { self, nixpkgs, home-manager, darwin, nur }:
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
          inputs = { inherit darwin home-manager nixpkgs; };
        };
        # Output for NixOS PC
        ikigai = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/ikigai/configuration.nix
            {
              home-manager.users.lillycham =
                homeManagerConfFor ./hosts/ikigai/home.nix;
            }
          ];
        };
        oracle = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          modules = [
            homeManagerConfFor ./hosts/oracle-arm/home.nix
          ];
        };
        # Call a home manager config with overlays
        homeManagerConfFor = config:
          { ... }: {
            nixpkgs.overlays = [
              nur.overlay
            ];
            imports = [ config ];
          };
    in
    {
      darwinConfigurations.mirai = mirai;
      defaultPackage.aarch64-darwin = mirai.system;
      homeConfigurations.oracle = oracle;
      nixosConfigurations."ikigai" = ikigai;
      defaultPackage.aarch64-linux = oracle.activationPackage;
    };
}
