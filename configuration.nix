{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- Базовые настройки системы ---
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "nixos";

  # --- Time and locale ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Включите поддержку NTFS в ядре
  boot.supportedFilesystems = [ "ntfs" ];

  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    useOSProber = true;
    device = "nodev"; # обязательно, если EFI
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="373b", MODE="0666", GROUP="wheel"
    '';


  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

  # Graphics - NVIDIA для RTX 5070
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us";
  };

  hardware.nvidia = {
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

  # Для Wayland
  services.xserver.displayManager.gdm.wayland = true;

  # Sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

fonts = {
    packages = with pkgs; [
           nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
	nerd-fonts.symbols-only
	font-awesome
	fira-code
	jetbrains-mono
	  nerd-fonts.jetbrains-mono  # ← JetBrains с иконками
  nerd-fonts.fira-code       # ← Fira Code с иконками
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font" "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Fira Code" ];
      };
    };
  };

  services.libinput.enable = true;

  # Sudo
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Users
  users.users.User = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "input" "lxd"];
    hashedPassword = lib.mkDefault null;
  };

  # Используем весь HDD как swap
  # swapDevices = [
  #   {
  #     device = "/dev/sda1";
  #     priority = 0;
  #   }
  # ];

  # Максимальные настройки для swap
  # boot.kernel.sysctl = {
  #   "vm.swappiness" = 5;
  #   "vm.vfs_cache_pressure" = 500; # АГРЕССИВНО очищать кэш
  #   "vm.dirty_background_ratio" = 5;
  #   "vm.dirty_ratio" = 10;
  #   "vm.watermark_scale_factor" = 200; # Раньше начинать очистку
  # };

	programs.zsh = {
	    enable = true;
	    
	    # Oh My Zsh - фреймворк с плагинами и темами
	    ohMyZsh = {
	      enable = true;
	      plugins = [ "git" "python" "sudo" "docker" ];
	      theme = "agnoster";  # Популярная тема
	    };
	    
	    # Автодополнение
	    autosuggestions.enable = true;
	    syntaxHighlighting.enable = true;
	  };
	
	# Сделать zsh оболочкой по умолчанию для пользователя
	 users.users.User.shell = pkgs.zsh;
	
         services.ratbagd.enable = true;

         # Включить Waydroid и необходимые сервисы
  virtualisation.waydroid.enable = true;
  virtualisation.lxd.enable = true;

  # Для ускорения графики (рекомендуется)
  virtualisation.lxc.lxcfs.enable = true;

	hardware.opentabletdriver = {
  enable = true;
  daemon = {
    enable = true;
  };
};

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim-full wget git curl unzip btop micro direnv usbutils
    
    # GUI applications
    firefox chromium vscode discord telegram-desktop obsidian
    obs-studio gimp libreoffice zoom-us teamspeak3
    nautilus gnome-tweaks pavucontrol piper prismlauncher
    rofi-wayland rofi-calc rofi-emoji kitty waybar
    networkmanagerapplet blueman bluez bluez-tools
    
    # Wayland utilities
    grim slurp wl-clipboard
    
    # Hyprland ecosystem
    hyprpaper hyprpicker
    
    # Gaming & Wine
    steam wine winetricks lutris gamemode gamescope
    steam-run-native protonup-qt virtualbox
    
    # Python & development
    python313 python312 python310 python313Packages.pip uv
    gcc cmake gnumake
    
    # Networking & VPN
    openvpn onedrive whatsie
    
    # Drivers & device support
    nvidia-vaapi-driver opentabletdriver libratbag
    
    # Miscellaneous
    arduino-ide xorg.xhost os-prober nixos-generators
  ];

  programs.zsh.interactiveShellInit = ''
    eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
  '';

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamemode.enable = true;

  # OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # NetworkManager
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [ 
      27036 27037 # Steam
    ];
    allowedUDPPorts = [ 
      27031 27036  # Steam
      4380  # Steam In-Home Streaming
    ];
  };
  
  # Docker
  virtualisation.docker = {
  enable = true;
  # Use the rootless mode - run Docker daemon as non-root user
  rootless = {
    enable = true;
    setSocketVariable = true;
  };
};

boot.extraModulePackages = with config.boot.kernelPackages; [ 
  virtualbox
];
users.extraGroups.vboxusers.members = [ "User" ];


  programs.firefox.enable = true;

  system.stateVersion = "25.05";
}
