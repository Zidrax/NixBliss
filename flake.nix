{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Home Manager соответствующей версии
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    antigravity-nix.url = "github:jacopone/antigravity-nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    username = "User"; # Менять при необходимости
    specialArgs = { inherit inputs username; };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }

        ./default.nix
        ./hardware-configuration.nix

        # Подключаем Home Manager как модуль NixOS
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.${username} = import ./home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
