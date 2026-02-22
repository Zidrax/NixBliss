{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, antigravity-nix, ... }@inputs:
    let
      username = "User"; 

    in {
      nixosConfigurations = {
        # Конфигурация для ПК
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username; hostname = "nixos"; };

          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./default.nix
            ./hardware-configuration.nix
            ./pc-only.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs username; hostname = "nixos"; };
              home-manager.users.${username} = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
            {
              environment.systemPackages = [
                antigravity-nix.packages.x86_64-linux.default
              ];
            }
          ];
        };

        # Конфигурация для Ноутбука (на будущее)
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username; hostname = "laptop"; };

          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./default.nix
            ./hardware-configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs username; hostname = "laptop"; };
              home-manager.users.${username} = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
