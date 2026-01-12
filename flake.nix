{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      username = "User"; 
      specialArgs = { inherit inputs username; };
    in {
      nixosConfigurations = {
        # Конфигурация для ПК
        nixos = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./default.nix
            ./hardware-configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs; # Оставили только эту строку
              home-manager.users.${username} = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
        };

        # Конфигурация для Ноутбука (на будущее)
        laptop = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./default.nix
            ./hardware-configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
