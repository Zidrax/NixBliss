{ config, lib, pkgs, username, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../profiles/system/common.nix
    ../../profiles/system/desktop.nix
    ../../profiles/system/nvidia.nix
    ../../profiles/system/virtualization.nix
    ../../profiles/system/gaming.nix
  ];

  networking.hostName = "laptop";

  # --- Загрузчик ---
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    
    # Настройки swap
    kernel.sysctl = {
      "vm.swappiness" = 5;
      "vm.vfs_cache_pressure" = 100;
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
      "vm.watermark_scale_factor" = 200;
      "net.ipv4.ip_forward" = 1;
      "kernel.unprivileged_userns_clone" = 1;
    };

    # extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
  };

  # --- Системные пакеты ---
  environment.systemPackages = with pkgs; [
    # --- Системные утилиты (CLI) ---
    vim wget git curl unzip btop micro direnv usbutils 
    pciutils lshw file tree killall

    # --- Звук и Сеть ---
    pavucontrol     # Контроль звука (нужен всем)
    networkmanagerapplet
    blueman         # Bluetooth менеджер

    # --- Wayland база (скриншоты, буфер) ---
    wl-clipboard    # Буфер обмена
    grim slurp      # Скриншоты (можно и в home, но удобно иметь глобально)

    # --- Драйверы и железо ---
    nvidia-vaapi-driver
    opentabletdriver

    # --- Администрирование ---
    os-prober
    nixos-generators
    xorg.xhost

    # --- Совместимость ---
    wine winetricks android-studio android-tools
  ];
}

