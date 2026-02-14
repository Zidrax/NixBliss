{ config, lib, pkgs, username, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "25.11";

  # --- Базовые настройки системы ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixos";

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
      "net.ipv4.ip_forward" = 1;
    };

    # extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
  };

  # --- Аппаратное обеспечение ---
  hardware = {
    # NVIDIA
    nvidia = {
      open = true; # ВАЖНО - для старых карт поменять на false 
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
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."99-input-mixing" = {
  "context.modules" = [
    {
      name = "libpipewire-module-loopback";
      args = {
        "node.description" = "Stream + Mic Mix";
        "capture.props" = {
          "node.name" = "stream_mic_mix_input";
          "media.class" = "Audio/Sink";
          "audio.position" = [ "FL" "FR" ];
        };
        "playback.props" = {
          "node.name" = "stream_mic_mix_output";
          "media.class" = "Audio/Source";
          "audio.position" = [ "FL" "FR" ];
        };
      };
    }
  ];
};
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
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "input" "incus-admin" "dialout" "uucp" "kvm" "adbusers" "libvirtd" "kvm-intel"];
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
      enable = true;
      allowedTCPPorts = [ 5000 27036 27037 ];
      
      # Объединяем все UDP порты здесь:
      allowedUDPPorts = [ 
        27031 27036 4380          # Steam порты
      ];
    };

    nftables.enable = true;
  };

  # --- Программы и утилиты ---
  programs = {
    zsh = {
      enable = true;
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
    };
  };

    gamemode.enable = true;
    firefox.enable = true;
    adb.enable = true;
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
    
    incus.enable = true;
    libvirtd.enable = true;
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

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Базовые зависимости
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat

    # Системные и DB
    libuuid
    libxcrypt
    readline
    sqlite
    glib
    libxml2
    libxslt

    # Графика и UI
    libGL
    libxkbcommon
    fontconfig
    freetype
    tcl
    tk


    # Библиотеки X11 (находятся в xorg)
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXrandr
    xorg.libXinerama

    # Для численных вычислений
    openblas

    vulkan-loader
    libglvnd
    mesa
    libdrm
    xorg.libXcomposite
  ];
}

