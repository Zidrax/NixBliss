{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  imports = [ 
    ./packages.nix 
    ./nvim.nix 
    ./firefox.nix 
    ./shell.nix 
    ./git.nix 
    ./waybar.nix 
    ./rofi.nix 
    ./hyprland.nix 
    ./ssh.nix 
  ];

  programs.home-manager.enable = true;
}

