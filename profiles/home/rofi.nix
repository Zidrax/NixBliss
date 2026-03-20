{ config, pkgs, ... }:

{
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
}

