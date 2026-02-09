{ config, pkgs, inputs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Твои пользовательские пакеты (те, что не нужны всей системе)
  home.packages = with pkgs; [
    # --- Интернет и Общение ---
    chromium            # Запасной браузер
    discord
    telegram-desktop
    element-desktop
    zoom-us
    networkmanager_dmenu brightnessctl pamixer blueman
    throne

    # --- Dev ---
    vscode antigravity
    dbeaver-bin         # Data bases
    sqlitebrowser
    sqlite
    nodejs_20
    uv                  # Python tools
    gcc cmake gnumake   # C/C++ сборка
    arduino-ide

    # --- Офис и Заметки ---
    obsidian
    libreoffice
    homebank            # Учет финансов
    xournalpp           # Рукописные заметки
    glow                # Markdown в терминале
    apostrophe          # Markdown редактор

    # --- Графика и Медиа ---
    gimp
    imv                 # Просмотрщик картинок (легкий)
    amberol             # Музыка
    obs-studio

    # --- Инструменты GUI ---
    nautilus            # Файловый менеджер
    gnome-tweaks        # Настройка GTK тем
    rofi-calc           # Калькулятор в Rofi
    rofi-emoji          # Эмодзи пикер
    #hyprpicker          # Пипетка цвета
    hyprpaper           # Обои (если не запускаешь демоном)
    kitty

    # --- Игры ---
    prismlauncher       # Minecraft
    lutris
    protonup-qt         # Установка Proton-GE для Steam
    steam-run           # Запуск любых бинарников
  ];

  # Vim
  programs.vim = {
    enable = true;

    # Список плагинов
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-nix
      nerdtree
      coc-nvim
      gruvbox-community
      auto-pairs
    ];

    settings = {
      number = true;
      relativenumber = false;
      shiftwidth = 2;
      expandtab = true;
      mouse = "a";
    };


    extraConfig = ''
      " --- Визуал и интерфейс ---
      syntax on
      set termguicolors
      set background=dark
      colorscheme gruvbox
      set clipboard=unnamedplus
      set undofile

      set undodir=~/.vim/undodir

      " --- Настройка КУРСОРА (вертикальная линия в Insert mode) ---
      " 1 или 2 - блок, 3 или 4 - подчеркивание, 5 или 6 - вертикальная линия
      let &t_SI = "\e[6 q" " Режим вставки
      let &t_SR = "\e[4 q" " Режим замены
      let &t_EI = "\e[2 q" " Обычный режим (блок обратно)

      " --- ОТКЛЮЧЕНИЕ подсказок (Inlay Hints: *args, *values) ---
      autocmd User CocNvimInit call coc#config('inlayHint.enable', v:false)
      autocmd User CocNvimInit call coc#config('python.analysis.inlayHints.callArgumentNames', 'none')
      autocmd User CocNvimInit call coc#config('python.analysis.inlayHints.variableTypes', v:false)

      " Горячая клавиша для дерева файлов
      map <C-n> :NERDTreeToggle<CR>

      " Цвета меню автодополнения
      highlight Pmenu ctermbg=236 guibg=#282828 ctermfg=250 guifg=#ebdbb2
      highlight PmenuSel ctermbg=24 guibg=#458588 ctermfg=255 guifg=#ffffff
      highlight CocFloating ctermbg=236 guibg=#282828

      " --- Логика автодополнения и скобок ---
      set completeopt=noinsert,menuone,noselect
      set shortmess+=c
      let g:AutoPairsMapCR = 0 

      inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1) :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
      inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

      function! CheckBackspace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>" 

      inoremap <silent><expr> <space> coc#pum#visible() ? coc#pum#cancel() . "\<space>" : "\<space>"

      nmap <silent> gd <Plug>(coc-definition)
      nnoremap <silent> K :call ShowDocumentation()<CR>

      function! ShowDocumentation()
        if CocAction('hasProvider', 'hover')
          call CocActionAsync('doHover')
        else
          call feedkeys('K', 'in')
        endif
      endfunction
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

    initContent = ''
      zstyle ':completion:*:*:*:*' ignored-patterns '*.lock'
    '';

    # Если используешь Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "python" "docker"];
      theme = "robbyrussell";
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

  home.file.".local/bin/set-sensitivity.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      # --- 1. СБОР ДАННЫХ ---

      # Сенса: -1..1 -> 0..1
      S_REAL=$(hyprctl getoption input:sensitivity | grep "float:" | awk '{print $2}')
      S_USER=$(awk -v val="$S_REAL" 'BEGIN {print (val + 1) / 2}')

      # Яркость: %
      B_VAL=$(brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d %)
      [ -z "$B_VAL" ] && B_VAL="N/A"

      # Звук: % (через pamixer, так надежнее)
      VOL_VAL=$(pamixer --get-volume)
      MIC_VAL=$(pamixer --default-source --get-volume)

      # --- 2. ГЛАВНОЕ МЕНЮ ---
      # Формат: "Иконка  Название (Текущее значение)"

      # Опции меню
      OPT_WIFI="  WiFi Menu"
      OPT_BT="  Bluetooth"
      OPT_SENS="  Sensitivity ($S_USER)"
      OPT_BRIGHT="  Brightness ($B_VAL%)"
      OPT_VOL="  Volume ($VOL_VAL%)"
      OPT_MIC="  Mic Volume ($MIC_VAL%)"

      # Показываем Rofi (высота 500px берется из твоего глобального конфига)
      CHOICE=$(echo -e "$OPT_WIFI\n$OPT_BT\n$OPT_VOL\n$OPT_MIC\n$OPT_BRIGHT\n$OPT_SENS" | rofi -dmenu -p "Settings")

      # --- 3. ЛОГИКА ---

      case "$CHOICE" in
          "$OPT_WIFI")
              # Запускает networkmanager_dmenu (если установлен) или nmtui в терминале
              if command -v networkmanager_dmenu >/dev/null; then
                  networkmanager_dmenu
              else
                  kitty -e nmtui
              fi
              ;;

          "$OPT_BT")
              # Запускает графический менеджер Bluetooth
              blueman-manager
              ;;

          "$OPT_SENS")
              VAL=$(echo "" | rofi -dmenu -p "Sens (0 - 1)" -theme-str 'listview { enabled: false; }')
              if [ -n "$VAL" ]; then
                  NEW_SENS=$(awk -v val="$VAL" 'BEGIN {print val * 2 - 1}')
                  hyprctl keyword input:sensitivity "$NEW_SENS"
              fi
              ;;

          "$OPT_BRIGHT")
              VAL=$(echo "" | rofi -dmenu -p "Brightness (0 - 100)" -theme-str 'listview { enabled: false; }')
              if [ -n "$VAL" ]; then
                  brightnessctl set "$VAL"%
              fi
              ;;

          "$OPT_VOL")
              VAL=$(echo "" | rofi -dmenu -p "Volume (0 - 100)" -theme-str 'listview { enabled: false; }')
              if [ -n "$VAL" ]; then
                  pamixer --set-volume "$VAL"
              fi
              ;;

          "$OPT_MIC")
              VAL=$(echo "" | rofi -dmenu -p "Mic Level (0 - 100)" -theme-str 'listview { enabled: false; }')
              if [ -n "$VAL" ]; then
                  pamixer --default-source --set-volume "$VAL"
              fi
              ;;
      esac
    '';
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
        "DP-1,preferred,auto,1"
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
        "waybar & hyprpaper"
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
        sensitivity = -0.5;

        touchpad = {
          natural_scroll = true; # "Естественная" прокрутка
          scroll_factor = 0.5;   # Скорость прокрутки 
          tap-to-click = true;   # Тап вместо нажатия
          clickfinger_behavior = true; # Правый клик двумя пальцами
        };
      };

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

  # Переносим конфиг обоев
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = /home/User/Pictures/Wallpaper/wl1.jpg
    wallpaper = DP-1, /home/User/Pictures/Wallpaper/wl1.jpg
    wallpaper = HDMI-A-1, /home/User/Pictures/Wallpaper/wl1.jpg
  '';
}
