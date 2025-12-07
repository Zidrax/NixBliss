# NixBliss 🌀

sudo nix-channel --add https://nixos.org/channels/nixos-25.05 nixos
sudo nix-channel --update

пока часть описания неактуальна, проект в разработке*
**Мощный, но элегантный менеджер пакетов Home Manager для Nix, вдохновленный Catppuccin.**

NixBliss — это не просто набор конфигураций. Это тщательно подобранный, готовый к использованию флейк (flake) для Home Manager, который приносит гармонию, стиль и производительность в вашу среду Nix. Он построен на эстетике Catppuccin и включает лучшие современные инструменты для комфортной разработки и работы.

[![Built with Home Manager](https://img.shields.io/badge/Built%20with-Home%20Manager-blue?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)
[![Catppuccin Theme](https://img.shields.io/badge/Theme-Catppuccin-pink?logo=catppuccin&logoColor=white)](https://catppuccin.com)
[![Nix Flake](https://img.shields.io/badge/Nix-Flake-informational?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)

## ✨ Особенности

*   **Готовая эстетика Catppuccin:** Прекрасные темы для всего стека (GTK, QT, терминал, редакторы) из коробки. В основном используется оттенок *Macchiato*.
*   **Современный стек разработчика:**
    *   **Терминал:** Fish с космической темой и полезными плагинами (экстракты, tide).
    *   **Оболочка:** Zsh с мощным prompt (starship) и умным дополнением (zsh-autosuggestions, zsh-syntax-highlighting).
    *   **Редактор:** Neovim с предварительно настроенным LSP (nvim-lspconfig, nvim-cmp) и деревом файлов (neo-tree).
    *   **Графическая среда:** Hyprland (Wayland композитор) с ключевыми компонентами (waybar, rofi, dunst), стилизованными под Catppuccin.
*   **Полная настройка окружения:** От шрифтов (JetBrainsMono, Noto) до утилит (bat, eza, fzf) и системных сервисов (udiskie).
*   **Структурированная и понятная архитектура:** Четкое разделение конфигураций по модулям (`modules/`), что позволяет легко включать, отключать или модифицировать компоненты.
*   **Надежная основа:** Построен на Home Manager, что обеспечивает декларативность, воспроизводимость и легкое управление пользовательской средой.

## 🚀 Быстрый старт

пока просто nix
1.  **Убедитесь, что у вас установлен Nix с поддержкой flakes** и Home Manager. Если нет, следуйте [официальному руководству](https://nixos.wiki/wiki/Flakes).

2.  **Добавьте этот флейк в свой Home Manager конфиг** (`~/.config/home-manager/flake.nix`):

    ```nix
    {
      description = "Home Manager configuration";

      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # Добавляем NixBliss
        nixbliss.url = "github:Zidrax/NixBliss";
        # Опционально: закрепляем на определенной ревизии для стабильности
        # nixbliss.url = "github:Zidrax/NixBliss/ваша_ревизия";
      };

      outputs = { nixpkgs, home-manager, nixbliss, ... }: {
        # Пример для системы x86_64-linux
        defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

        homeConfigurations."ваше_имя_пользователя" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            # Импортируем профиль NixBliss. Выберите один:
            # nixbliss.homeProfiles.desktop # Полный графический профиль (Hyprland + Catppuccin)
            # nixbliss.homeProfiles.base    # Базовый консольный профиль (Fish/Zsh, темы, утилиты)

            # Ваши личные настройки поверх NixBliss
            ({ config, ... }: {
              home.username = "ваше_имя_пользователя";
              home.homeDirectory = "/home/ваше_имя_пользователя";
              # ... ваши переопределения
            })
          ];
        };
      };
    }
    ```

3.  **Активируйте конфигурацию:**
    ```bash
    # Переключиться на новый флейк-конфиг
    home-manager switch --flake ~/.config/home-manager
    ```

4.  **Перезайдите в систему** (или перезапустите сессию), чтобы изменения вступили в силу.

## 🗂️ Структура проекта
