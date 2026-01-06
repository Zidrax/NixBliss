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
    initExtra = ''
      # Твой ручной код из .zshrc
    '';

    # Если используешь Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "robbyrussell"; # Или та, которая у тебя сейчас
    };
  };
}
