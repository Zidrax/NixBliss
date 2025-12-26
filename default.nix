{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "25.05";

  # --- Базовые настройки системы ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixos";

  # --- Время и локализация ---
  time.timeZone = "Europe/Moscow";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  };
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

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
      "vm.vfs_cache_pressure" = 500;
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
      "vm.watermark_scale_factor" = 200;
    };
    
    # extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
  };

  # --- Аппаратное обеспечение ---
  hardware = {
    # NVIDIA
    nvidia = {
      open = true;
      modesetting.enable = true;
      forceFullCompositionPipeline = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    
    # Графика
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        intel-media-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    
    # Графический планшет
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  # --- Графика и отображение ---
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us";
  };

  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;

  services.libinput.enable = true;

  # --- Звук ---
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # --- Wayland и окружения ---
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # --- Шрифты ---
  fonts = {
    packages = with pkgs; [
      # Nerd Fonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.symbols-only
      
      # Обычные шрифты
      font-awesome
      fira-code
      jetbrains-mono
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font" "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Fira Code" ];
      };
    };
  };

  # --- Пользователи и права ---
  users.users.User = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "input" "incus-admin" ];
    hashedPassword = lib.mkDefault null;
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
      allowedTCPPorts = [ 27036 27037 ];
      allowedUDPPorts = [ 27031 27036 4380 ];
    };

    nftables.enable = true;
  };

  # --- Программы и утилиты ---
  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "python" "sudo" "docker" ];
        theme = "agnoster";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';
    };
    
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    throne = {
    enable = true;
    tunMode = {
      enable = true;
      # Дополнительные опции (опционально)
      # deviceName = "tun0";
      # implementation = "system";
    };
  };

    gamemode.enable = true;
    firefox.enable = true;
  };

  # --- Виртуализация ---
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    
    waydroid.enable = true;
    incus.enable = true;
    lxc.lxcfs.enable = true;
  };

  # --- Дополнительные сервисы ---
  services = {
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="373b", MODE="0666", GROUP="wheel"
    '';
    ratbagd.enable = true;
  };

  # --- Системные пакеты ---
  environment.systemPackages = with pkgs; [
    # Основные утилиты
    vim-full wget git curl unzip btop micro direnv usbutils
    
    # Графические приложения
    firefox chromium vscode discord telegram-desktop obsidian
    gimp libreoffice #  zoom-us teamspeak3 obs-studio
    nautilus gnome-tweaks pavucontrol piper prismlauncher
    rofi rofi-calc rofi-emoji kitty waybar
    networkmanagerapplet blueman bluez bluez-tools
    
    # Wayland утилиты
    grim slurp wl-clipboard
    
    # Hyprland
    hyprpaper hyprpicker
    
    # Игры и Wine
    steam wine winetricks lutris gamemode gamescope
    steam-run protonup-qt #virtualbox
    
    # Python и разработка
    python313 python312 python310 python313Packages.pip uv
    gcc cmake gnumake
    
    # Сеть и VPN
    openvpn onedrive
    
    # Драйверы и устройства
    nvidia-vaapi-driver opentabletdriver libratbag
    
    # Прочее
    arduino-ide xorg.xhost os-prober nixos-generators

    # Потом разбить на категории
    throne 
    #v2rayn
    networkmanager_dmenu
  ];

  # --- Swap ---
  swapDevices = [{
    device = "/dev/sda1";
    priority = 0;
  }];
  
}

