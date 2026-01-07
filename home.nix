{ config, pkgs, inputs, ... }:

{
  home.username = "User";
  home.homeDirectory = "/home/User";
  home.stateVersion = "25.11";

  # Программы, которыми управляет Home Manager
  programs.home-manager.enable = true;

  # Твои пользовательские пакеты (те, что не нужны всей системе)
  home.packages = with pkgs; [
    jami
    simplex-chat-desktop
    element-desktop

    inputs.antigravity-nix.packages.${pkgs.system}.default
  ];

  # Vim
  programs.vim = {
    enable = true;

    #plugins
    plugins = with pkgs.vimPlugins; [
      vim-airline      # Красивая статусная строка
      vim-nix          # Подсветка синтаксиса Nix
      nerdtree         # Дерево файлов
    ];

    # Настройки .vimrc в формате Nix
    settings = {
      number = true;         # Включить номера строк
      relativenumber = false; # Относительные номера строк
      shiftwidth = 2;        # Размер отступа
      expandtab = true;      # Использовать пробелы вместо табуляции
      mouse = "a";           # Поддержка мыши
    };
    # Дополнительный конфиг (традиционный синтаксис vimrc)
    extraConfig = ''
      syntax on
      set clipboard=unnamedplus
      " Горячая клавиша для дерева файлов
      map <C-n> :NERDTreeToggle<CR>
    '';
  };

  # Firefix  
  programs.firefox = {
    enable = true;
    profiles.User = {
      isDefault = true;

      settings = {
        # --- ВОССТАНОВЛЕНИЕ СЕССИИ (Твои вкладки) ---
        "browser.startup.page" = 3;               # 3 = Восстанавливать предыдущую сессию
        "browser.startup.homepage" = "about:blank"; # Новое окно всё равно будет чистым

        # --- ПАРОЛИ (Раз ты ими пользуешься) ---
        "signon.rememberSignons" = true;          # Вернул возможность сохранять пароли

        # --- МИНИМАЛИЗМ (Оставляем как было) ---
        "browser.newtabpage.enabled" = false;
        "extensions.pocket.enabled" = false;
        "browser.tabs.firefox-view" = false;
        "browser.aboutConfig.showWarning" = false;

        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.vpn_promo.enabled" = false;
        "browser.promo.focus.enabled" = false;

        "places.history.enabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "datareporting.healthreport.uploadEnabled" = false;
      };
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Твои алиасы (сокращения команд)
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
      ll = "ls -l";
      v = "vim";
    };

    # Всё, что нельзя описать стандартными опциями, пойдет сюда
    initContent = ''
      # Твой ручной код из .zshrc
    '';

    # Если используешь Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "robbyrussell"; # Или та, которая у тебя сейчас
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

    style = ''
      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 0;
          padding: 0;
          box-shadow: none;
          text-shadow: none;
          font-family: "JetBrains Mono Nerd Font", "Fira Code", sans-serif;
          font-size: 14px;
      }

      #waybar {
          background: transparent;
      }

      #workspaces button {
          padding: 0 10px;
          background: transparent;
          transition: color 0.2s ease;
          color: #f38ba8;
      }

      #window {
          color: rgba(245, 255, 250, 0.6);
          transition: color 0.2s ease;
      }

      #window:hover {
          color: rgba(245, 255, 250, 1);
      }

      .modules-center {
          background: rgba(0, 0, 0, 0.7);
          border-radius: 152px;
          padding: 7px 12px;
      }

      .modules-right {
          background: rgba(0, 0, 0, 0.7);
          border-radius: 152px;
          padding: 7px 12px;
      }

      #language, #tray, #clock, #battery, #pulseaudio, #network, #cpu, #temperature, #backlight, #custom-power, #power-profiles-daemon, #bluetooth {
          color: bisque;
          padding: 0 7px;
      }

      #custom-power {
          color: coral;
      }
    '';
  };

  #Rofi
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      display-drun = "   "; # Иконка поиска вместо текста APPS
      drun-display-format = "{name}";
      font = "JetBrainsMono Nerd Font 12";
    };

  theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";
        bg-alt = mkLiteral "#313244";
        border-col = mkLiteral "#fab387"; # Тот самый оранжевый
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
        height = mkLiteral "500px"; # ФИКСИРОВАННАЯ ВЫСОТА ОКНА
      };

      "mainbox" = {
        children = mkLiteral "[ inputbar, listview ]";
        spacing = mkLiteral "10px";
      };

      "inputbar" = {
        children = mkLiteral "[ prompt, entry ]";
        background-color = mkLiteral "@bg-alt";
        border = mkLiteral "1px";
        border-color = mkLiteral "@border-col";
        border-radius = mkLiteral "8px";
        padding = mkLiteral "10px";
        margin = mkLiteral "0px 0px 10px 0px";
      };

      "listview" = {
        columns = 2;
        lines = 8;
        spacing = mkLiteral "5px";
        fixed-height = true; # ТЕПЕРЬ РАЗМЕР НЕ БУДЕТ СКАКАТЬ
        scrollbar = false;
      };

      "element" = {
        padding = mkLiteral "10px";
        border-radius = mkLiteral "8px";
        background-color = mkLiteral "transparent";
      };

      "element selected" = {
        background-color = mkLiteral "@bg-alt";
        text-color = mkLiteral "@border-col"; # Оранжевый текст при выборе
        border = mkLiteral "1px";
        border-color = mkLiteral "@border-col";
      };

      # Нужно явно указать цвет текста внутри элементов, чтобы он наследовался
      "element-text" = {
        text-color = mkLiteral "inherit";
        background-color = mkLiteral "transparent";
      };
      
      "element-icon" = {
        size = mkLiteral "32px";
        background-color = mkLiteral "transparent";
      };
    };
  };


  home.file.".local/bin/powermenu.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      chosen=$(printf "  Shutdown\n  Reboot\n  Suspend\n  Lock" | rofi -dmenu -p "Power Action" -theme-str 'window {width: 300px;}')

      case "$chosen" in
          *Shutdown) systemctl poweroff ;;
          *Reboot) systemctl reboot ;;
          *Suspend) systemctl suspend ;;
          *Lock) hyprlock ;; # Или swaylock, смотря что используешь
      esac
    '';
  };
}
