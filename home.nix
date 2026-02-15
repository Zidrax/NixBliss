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
    kitty

    # --- Игры ---
    prismlauncher       # Minecraft
    lutris
    protonup-qt         # Установка Proton-GE для Steam
    steam-run           # Запуск любых бинарников

    nixd
    pyright
    clang-tools
    ollama
  ];


  # NVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Ставим плагины через Nix (воспроизводимость!)
    plugins = with pkgs.vimPlugins; [
      # --- UI и Внешний вид ---
      gruvbox-nvim          # Твоя тема, но на Lua
      lualine-nvim          # Замена airline
      nvim-web-devicons     # Иконки для файлов
      nvim-tree-lua         # Замена NERDTree
      rainbow-delimiters-nvim

      # --- Основа (LSP и Treesitter) ---
      nvim-treesitter.withAllGrammars  # Умная подсветка для всего
      nvim-lspconfig        # Настройки LSP серверов

      # --- Автодополнение (Замена CoC) ---
      nvim-cmp              # Движок автодополнения
      cmp-nvim-lsp          # Источник: LSP
      cmp-buffer            # Источник: слова из буфера
      cmp-path              # Источник: пути к файлам
      luasnip               # Сниппеты (нужны для cmp)
      cmp_luasnip

      # --- Утилиты ---
      nvim-autopairs        # Авто-скобки
      comment-nvim          # Быстрое комментирование (gcc)
    ];

    extraLuaConfig = ''
      -- 1. БАЗОВЫЕ НАСТРОЙКИ
      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.expandtab = true
      vim.opt.mouse = "a"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true
      vim.opt.undofile = true
      
      -- Таймер автосейва (миллисекунды)
      vim.opt.updatetime = 500

      -- Тема
      vim.o.background = "dark"
      vim.cmd("colorscheme gruvbox")

      -- 2. LUALINE
      require('lualine').setup { options = { theme = 'gruvbox' } }

      -- 3. NVIM-TREE (Файловый менеджер)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      local api = require("nvim-tree.api")
      require("nvim-tree").setup()

      -- ИСПРАВЛЕННАЯ ЛОГИКА WIN+N (Без is_focused)
      local function toggle_tree_focus()
        if not api.tree.is_visible() then
          api.tree.open()
        else
          -- Проверяем, находится ли фокус сейчас на дереве
          if vim.bo.filetype == "NvimTree" then
            api.tree.close()
          else
            api.tree.focus()
          end
        end
      end
      
      vim.keymap.set('n', '<C-n>', toggle_tree_focus, { silent = true })

      -- 4. TREESITTER
      require'nvim-treesitter.configs'.setup {
        highlight = { enable = true },
        indent = { enable = true },
      }

      -- 5. LSP (ФИКС ДЛЯ NEOVIM 0.11)
      -- Мы больше не делаем require('lspconfig').setup, это вызывает ошибку.
      -- Мы используем нативный vim.lsp.enable
      
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local servers = { 'pyright', 'nixd', 'clangd' }

      -- Функция для добавления дефолтных конфигов из lspconfig в vim.lsp.config
      -- Это хак для clean setup на unstable версиях
      local lsp_configs = require('lspconfig.configs')

      for _, name in ipairs(servers) do
        -- Если конфига еще нет в глобальной таблице vim, берем дефолтный из плагина
        if not vim.lsp.config[name] and lsp_configs[name] then
           vim.lsp.config[name] = lsp_configs[name].default_config
        end
        
        -- Добавляем capabilities (автодополнение)
        if vim.lsp.config[name] then
            vim.lsp.config[name].capabilities = capabilities
            -- Включаем сервер
            vim.lsp.enable(name)
        end
      end

      -- 6. AUTOPAIRS
      require('nvim-autopairs').setup{}

      -- 7. CMP (Автодополнение)
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        })
      })

      -- 8. АВТОСЕЙВ (Работает по таймеру updatetime)
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("autosave", {}),
        callback = function()
          if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
            vim.api.nvim_command('silent update')
          end
        end,
      })

      -- 9. RAINBOW DELIMITERS
      require('rainbow-delimiters.setup').setup { }
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
      function gcommit() {
        git diff --cached | ollama run llama3 "Ты — генератор git commit сообщений. Проанализируй этот diff и напиши ТОЛЬКО сообщение коммита (первая строка — заголовок до 50 символов, затем пустая строка, затем описание). Без лишних слов."
      }
    '';

    # Если используешь Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "python" "docker"];
      theme = "robbyrussell";
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

    style = builtins.readFile ./waybar/style.css;
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
    source = ./scripts/powermenu.sh;
  };

  home.file.".local/bin/set-sensitivity.sh" = {
    executable = true;
    source = ./scripts/set-sensitivity.sh;
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
        "waybar"
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

        gestures = {
          workspace_swipe = true;         # Включает жесты смахивания
          workspace_swipe_fingers = 4;    # Устанавливает количество пальцев (по умолчанию 3)
          workspace_swipe_forever = true; # Позволяет листать бесконечно, а не останавливаться на краях
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
        "$mainMod, L, exec, hyprlock"

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
}
