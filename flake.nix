{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, antigravity-nix, ... }@inputs:
    let
      username = "User"; 

    in {
      nixosConfigurations = {
        # Конфигурация для ПК
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username nixpkgs-unstable; hostname = "nixos"; };

          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/nixos/default.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs username; hostname = "nixos"; };
              home-manager.users.${username} = import ./profiles/home/common.nix;
              home-manager.backupFileExtension = "backup";
            }
            {
              environment.systemPackages = [
                antigravity-nix.packages.x86_64-linux.default
              ];
            }
          ];
        };

        # Конфигурация для Ноутбука
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username nixpkgs-unstable; hostname = "laptop"; };

        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/laptop/default.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username; hostname = "laptop"; };
            home-manager.users.${username} = import ./profiles/home/common.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
  };
}
