{ config, pkgs, inputs, username, hostname, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  xdg.desktopEntries = {
    telemost = {
      name = "Yandex Telemost";
      genericName = "Video Conferencing";
      exec = "chromium --app=https://telemost.yandex.ru";
      icon = "yandex-browser"; # Или "video-display", если иконка не подтянется
      terminal = false;
      categories = [ "Network" "VideoConference" ];
      comment = "Запустить Телемост как отдельное приложение";
    };
  };
  
  # Git
  programs.git = {
    enable = true;
    
    settings = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        margin-top = 10;
        margin-right = 20;
        margin-left = 20;
        spacing = 10;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "hyprland/language"
          "battery"
          "power-profiles-daemon"
          "pulseaudio"
          "network"
          "cpu"
          "temperature"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
          };
        };

        "hyprland/language" = {
          format = "{} ";
          on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
          format-en = "ENG";
          format-ru = "RUS";
        };

        "network" = {
          format-wifi = "{essid} ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected 󰖪";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          on-click-right = "networkmanager_dmenu";
        };

        "clock" = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };

        "cpu" = {
          format = "{usage}% ";
          tooltip = false;
        };

        "temperature" = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" ];
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        "tray" = {
          icon-size = 21;
          spacing = 10;
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
      };
    };

    style = builtins.readFile ../../waybar/style.css;
  };

  #Rofi
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];

    extraConfig = {
      modi = "drun,run,window,calc,emoji";
      show-icons = true;
      display-drun = "   "; # Иконка поиска вместо текста APPS
      drun-display-format = "{name}";
      font = "JetBrainsMono Nerd Font 12";
    };

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";     # Темный фон
        bg-alt = mkLiteral "#313244";     # Фон для строки поиска
        border-col = mkLiteral "#fab387"; # Оранжевый акцент
        fg-col = mkLiteral "#cdd6f4";
        
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };

      "window" = {
        padding = mkLiteral "20px";
        border = mkLiteral "2px";
        border-radius = mkLiteral "12px";
        border-color = mkLiteral "@border-col";
        width = mkLiteral "800px"; 
        height = mkLiteral "500px"; # ДОБАВЛЕНО: Фиксированная высота окна
      };

      "mainbox" = {
        children = mkLiteral "[ inputbar, listview ]";
        spacing = mkLiteral "10px";
      };

      # --- СТРОКА ПОИСКА (Тот самый Search Bar) ---
      "inputbar" = {
        children = mkLiteral "[ prompt, entry ]";
        background-color = mkLiteral "@bg-alt";
        border = mkLiteral "1px";
        border-color = mkLiteral "@border-col"; # Оранжевая рамка вокруг поиска
        border-radius = mkLiteral "8px";
        padding = mkLiteral "10px";
        margin = mkLiteral "0px 0px 10px 0px";
      };

      "prompt" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@border-col";
      };

      "entry" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg-col";
        placeholder = "Search...";
      };

      # --- СПИСОК (Две колонки) ---
      "listview" = {
        columns = 2; 
        lines = 8;
        spacing = mkLiteral "5px";
        fixed-height = true; # ИЗМЕНЕНО: Теперь размер не будет скакать
      };

      "element" = {
        padding = mkLiteral "10px";
        border-radius = mkLiteral "8px";
        background-color = mkLiteral "transparent";
      };

      "element-icon" = {
        size = mkLiteral "32px"; 
        margin = mkLiteral "0px 10px 0px 0px";
        background-color = mkLiteral "transparent";
      };

      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };

      # --- ВЫДЕЛЕНИЕ (Оранжевый текст) ---
      "element selected" = {
        background-color = mkLiteral "@bg-alt"; 
        text-color = mkLiteral "@border-col";   
        border = mkLiteral "1px";
        border-color = mkLiteral "@border-col"; 
      };
    };
  };

  home.file.".local/bin/powermenu.sh" = {
    executable = true;
    source = ../../scripts/powermenu.sh;
  };

  home.file.".local/bin/set-sensitivity.sh" = {
    executable = true;
    source = ../../scripts/set-sensitivity.sh;
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";
      "$menu" = "rofi -show drun";

      monitor = [
        "DP-1,2560x1440@120,auto,1"
        "HDMI-A-1,preferred,auto,1.333333"
      ];

      workspace = [
        "1, monitor:DP-1"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"
        "6, monitor:DP-1"
        "7, monitor:DP-1"
        "8, monitor:DP-1"
        "9, monitor:DP-1"
        "10, monitor:HDMI-A-1"
      ];

      exec-once = [
        "Throne"
        "waybar"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "[workspace 10] $terminal"
        "[workspace 1] obsidian"
        "sleep 2 && hyprctl dispatch exec \"[workspace 2]\" firefox"
        "[workspace 3] Telegram"
      ];

      env = [
        "XCURSOR_SIZE,16"
        "HYPRCURSOR_SIZE,16"
        "XCURSOR_THEME,Adwaita"
        "GTK_THEME,Adwaita-dark"
        "COLORSCHEME,dark"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      windowrulev2 = [
        "bordercolor rgba(ffb3b3ee) rgba(f7a8b8ee) 45deg, tag:ctf"
      ];

      decoration = {
        rounding = 10;
        "rounding_power" = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "workspaces, 1, 1.94, almostLinear, fade"
        ];
      };

      input = {
        kb_layout = "us, ru";
        kb_options = "grp:win_space_toggle";
        follow_mouse = 1;
        sensitivity = -1;

        touchpad = {
          natural_scroll = true; # "Естественная" прокрутка
          scroll_factor = 0.5;   # Скорость прокрутки 
          tap-to-click = true;   # Тап вместо нажатия
          clickfinger_behavior = true; # Правый клик двумя пальцами
        };
      };

      gesture = [
        "3, horizontal, workspace"
      ];

      bind = [
        "$mainMod, RETURN, exec, $terminal"
        "$mainMod, Q, killactive"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating"
        "$mainMod, D, exec, $menu"
        "$mainMod, M, exec, ~/.local/bin/powermenu.sh"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"
        "$mainMod SHIFT, V, exec, wl-paste > /tmp/clip_img && imv /tmp/clip_img"
        "$mainMod, I, exec, ~/.local/bin/set-sensitivity.sh"
        "$mainMod, L, exec, hyprlock"
        "$mainMod SHIFT, C, exec, rofi -show calc -modi calc -no-show-match -no-sort"
        "$mainMod, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mainMod SHIFT, P, exec, hyprpicker -a"
        "$mainMod, PERIOD, exec, rofi -show emoji -modi emoji"

        # Переключение воркспейсов
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # ПЕРЕМЕЩЕНИЕ МЫШКОЙ (Вернул скролл!)
        "$mainMod, mouse_up, workspace, e+1"
        "$mainMod, mouse_down, workspace, e-1"

        # Скриншоты
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim - | wl-copy"
        "CONTROL, Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S').png"

        # ПЕРЕМЕЩЕНИЕ ОКНА НА РАБОЧИЙ СТОЛ (Super + Shift + Цифра)
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Специальный воркспейс (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Мультимедиа
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };

    # Чтобы точно ничего не потерять, можно добавить оставшиеся правила сюда
    extraConfig = ''
      windowrule = suppressevent maximize, class:.*
    '';
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = true;
        grace = 0;
        disable_loading_bar = true;
      };

      background = [
        {
          path = "${config.home.homeDirectory}/Pictures/Wallpaper/wl1.jpg";
          blur_passes = 2;
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          size = "250, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          
          # ТЕКСТ (Белый, как fg-col в Rofi)
          font_color = "rgb(205, 214, 244)";
          
          # ФОН ПОЛЯ (Темно-серый, как bg-alt в Rofi)
          inner_color = "rgb(49, 50, 68)";
          
          # РАМКА (Оранжевый, как border-col в Rofi)
          outer_color = "rgb(250, 179, 135)";
          
          # ЦВЕТ ПРИ ПРОВЕРКЕ (Тоже оранжевый)
          check_color = "rgb(250, 179, 135)";
          
          # ЦВЕТ ОШИБКИ (Красный, стандарт)
          fail_color = "rgb(243, 139, 168)";

          outline_thickness = 2; # Как border 2px в Rofi
          placeholder_text = "<i>Password...</i>";
          shadow_passes = 2;
        }
      ];

      label = [
        # ЧАСЫ (Оранжевый акцент)
        {
          text = "$TIME";
          color = "rgb(250, 179, 135)"; 
          font_size = 85;
          font_family = "JetBrains Mono Nerd Font ExtraBold";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # ПРИВЕТСТВИЕ (Белый текст)
        {
          text = "Hi, $USER";
          color = "rgb(205, 214, 244)";
          font_size = 20;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [
        "${config.home.homeDirectory}/Pictures/Wallpaper/wl1.jpg"
      ];

      wallpaper = [
        "DP-1,${config.home.homeDirectory}/Pictures/Wallpaper/wl1.jpg"
        "HDMI-A-1,${config.home.homeDirectory}/Pictures/Wallpaper/wl1.jpg"
        ",${config.home.homeDirectory}/Pictures/Wallpaper/wl1.jpg"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";       # Сама команда блокировк
        before_sleep_cmd = "loginctl lock-session";    # Блочить, если вдруг уснул сам (например, закрыл крышку)
        after_sleep_cmd = "hyprctl dispatch dpms on";  # Включать монитор при пробуждении
      };

      listener = [
        {
          timeout = 300;                                # 5 минут
          # pidof hyprlock && ... означает "ТОЛЬКО если процесс hyprlock найден, то выполняй suspend"
          on-timeout = "pidof hyprlock && systemctl suspend"; 
        }
      ];
    };
  };


  # Kitty
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.8"; # Уровень прозрачности (от 0.0 до 1.0)
      dynamic_background_opacity = true; # Позволяет менять прозрачность на лету
    };
  };


  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "pi" = {
        hostname = "192.168.50.42";
        user = "user";
        # Агент (чтобы ключи для гитхаба с ПК работали на устройсте)
        forwardAgent = true; 

        # Аналог флага -Y (Trusted X11 Forwarding)
        forwardX11 = true;
        forwardX11Trusted = true;
      };
      "*" = {
        # serverAliveInterval = 60;
      };
    };
  };
}

