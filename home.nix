{ config, pkgs, ... }:

{
  home.username = "User";
  home.homeDirectory = "/home/User";
  home.stateVersion = "25.11";

  # Программы, которыми управляет Home Manager
  programs.home-manager.enable = true;

  # Твои пользовательские пакеты (те, что не нужны всей системе)
  home.packages = with pkgs; [
    jami
  ];
}
