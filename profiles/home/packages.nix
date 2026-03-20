{ config, pkgs, inputs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # --- Интернет и Общение ---
    chromium            # Запасной браузер
    tor-browser
    telegram-desktop element-desktop zoom-us
    networkmanager_dmenu brightnessctl pamixer blueman
    throne
    nmap


    # ---- Dev ----
    vscode
    dbeaver-bin         # Data bases
    sqlitebrowser
    sqlite
    nodejs_20
    uv                  # Python tools
    gcc cmake gnumake   # C/C++ сборка
    arduino-ide
    pyright
    imhex
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex
    github-cli


    # ---- Офис и Заметки ----
    obsidian
    libreoffice
    homebank            # Учет финансов
    xournalpp           # Рукописные заметки
    apostrophe          # Markdown редактор


    # ---- Графика и Медиа ----
    gimp
    imv                 # Просмотрщик картинок (легкий)
    amberol             # Музыка
    obs-studio kooha
    scrcpy


    # ---- Инструменты GUI ----
    nautilus            # Файловый менеджер
    gnome-tweaks        # Настройка GTK тем
    hyprpicker          # Пипетка цвета
    kitty
    cliphist
    hyprshot


    # ---- Игры ----
    prismlauncher       # Minecraft
    lutris
    protonup-qt         # Установка Proton-GE для Steam
    steam-run           # Запуск любых бинарников

    nixd
    clang-tools
    ollama
    impression
    termscp termius
    docker docker-compose lazydocker
    dockerfile-language-server yaml-language-server
    ripgrep
    distrobox
  ];
}
