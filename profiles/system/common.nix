{ config, lib, pkgs, username, ... }:

{
  system.stateVersion = "25.11";

  # --- Базовые настройки системы ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Время и локализация ---
  time.timeZone = "Europe/Berlin";
  #time.timeZone = "Europe/Moscow";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  };
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # --- Пользователи и права ---
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "input" "incus-admin" "dialout" "uucp" "kvm" "adbusers" "libvirtd" "kvm-intel" "wireshark"];
    initialPassword = "1234";
    shell = pkgs.zsh;
  };
  
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  # --- Сеть ---
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
    
    firewall = {
      enable = true;
      allowedTCPPorts = [ 3000 5000 8000 27036 27037 ];
    };

    nftables.enable = true;
  };

}
