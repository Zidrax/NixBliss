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
      relativenumber = true; # Относительные номера строк
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
}
