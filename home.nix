{ config, pkgs, ... }:

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

  programs.firefox = {
    enable = true;
    profiles.User = {
      isDefault = true;
      
      settings = {
        # --- ИНТЕРФЕЙС И МИНИМАЛИЗМ ---
        "browser.startup.page" = 0;              # 0 = пустая страница при запуске
        "browser.startup.homepage" = "about:blank"; 
        "browser.newtabpage.enabled" = false;     # Чистая новая вкладка (без топов сайтов)
        
        "extensions.pocket.enabled" = false;      # Полностью отключить Pocket
        "browser.tabs.firefox-view" = false;      # Убрать иконку Firefox View (вверху слева)
        "browser.aboutConfig.showWarning" = false; # Не бесить предупреждением в about:config
        
        # --- ОТКЛЮЧЕНИЕ РОЖИ И СПАМА ---
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Убрать статьи
        "browser.newtabpage.activity-stream.showSponsored" = false;            # Убрать рекламу
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.vpn_promo.enabled" = false;                                   # Убрать рекламу VPN
        "browser.promo.focus.enabled" = false;
        
        # --- ИСТОРИЯ И ПАРОЛИ ---
        "places.history.enabled" = true;          # ИСТОРИЯ СОХРАНЯЕТСЯ (как ты просил)
        "signon.rememberSignons" = false;         # Не предлагать сохранять пароли (для минимализма)
        
        # --- СИСТЕМНОЕ ---
        "browser.shell.checkDefaultBrowser" = false; # Не спрашивать про "браузер по умолчанию"
        "datareporting.healthreport.uploadEnabled" = false; # Меньше телеметрии
      };
    };
  };  
}
