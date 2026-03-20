{ config, lib, pkgs, ... }:
{
  # --- Сервисы ---
  services = {
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="373b", MODE="0666", GROUP="wheel"
    '';
    ratbagd.enable = true;

    # --- Графика и отображение ---
    xserver = {
      enable = true;
      xkb.layout = "us";
    };

    avahi = {
      enable = true;
      nssmdns4 = true; # Позволяет системе разрешать .local адреса
      openFirewall = true; # Автоматически открывает нужные порты в вашем firewall 
    };

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;

    libinput.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda"; #cude - NVIDIA, rocm - AMD, null - CPU 
    };

    # --- Звук ---
    pipewire = {
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

  # --- Программы и утилиты ---
  programs = {
    zsh = {
      enable = true;
    };

    throne = {
      enable = true;
      tunMode = {
        enable = true;
      };
    };

    # --- Wayland и окружения ---
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    firefox.enable = true;
    adb.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
        stdenv.cc.cc zlib fuse3 icu nss openssl curl expat
        libuuid libxcrypt readline sqlite glib musl libxml2 libxslt
        libGL libxkbcommon fontconfig freetype tcl tk
        xorg.libXi xorg.libSM xorg.libxcb xorg.libICE xorg.libX11
        xorg.libXcursor xorg.libXext xorg.libXrender xorg.libXrandr xorg.libXinerama
        openblas vulkan-loader libglvnd mesa libdrm xorg.libXcomposite
      ];
  };
}
