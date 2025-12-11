#!/usr/bin/env bash

# Установочный скрипт для NixBliss
# Автоматическая установка и настройка конфигураций

set -e  # Выход при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Пути
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME/.config"

# Функции для вывода
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка, что скрипт запущен от root или с sudo
check_root() {
    if [[ $EUID -ne 0 ]]; then
        info "Скрипт требует привилегий root. Запрашиваю sudo..."
        if sudo -v; then
            info "Права получены"
        else
            error "Не удалось получить права root. Выход."
            exit 1
        fi
    fi
}

# Проверка наличия NixOS
check_nixos() {
    if [ ! -f /etc/NIXOS ]; then
        error "Этот скрипт предназначен только для NixOS!"
        exit 1
    fi
}

# Копирование конфигураций
copy_configs() {
    info "Копирование конфигурационных файлов..."
    
    # Создание директорий если их нет
    mkdir -p "$CONFIG_DIR/hypr"
    mkdir -p "$CONFIG_DIR/rofi"
    mkdir -p "$CONFIG_DIR/waybar"
    
    # Копирование hyprland конфигураций
    if [ -f "$SCRIPT_DIR/hyprland.conf" ]; then
        cp "$SCRIPT_DIR/hyprland.conf" "$CONFIG_DIR/hypr/"
        success "Hyprland конфигурация скопирована"
    else
        warning "Файл hyprland.conf не найден"
    fi
    
    if [ -f "$SCRIPT_DIR/hyprpaper.conf" ]; then
        cp "$SCRIPT_DIR/hyprpaper.conf" "$CONFIG_DIR/hypr/"
        success "Hyprpaper конфигурация скопирована"
    else
        warning "Файл hyprpaper.conf не найден"
    fi
    
    # Копирование rofi конфигураций
    if [ -d "$SCRIPT_DIR/rofi" ]; then
        mkdir -p "$CONFIG_DIR/rofi"
        cp -r "$SCRIPT_DIR/rofi/"* "$CONFIG_DIR/rofi/"
        success "Rofi конфигурации скопированы"
    else
        warning "Директория rofi не найдена"
    fi
    
    # Копирование waybar конфигураций
    if [ -d "$SCRIPT_DIR/waybar" ]; then
        mkdir -p "$CONFIG_DIR/waybar"
        cp -r "$SCRIPT_DIR/waybar/"* "$CONFIG_DIR/waybar/"
        success "Waybar конфигурации скопированы"
    else
        warning "Директория waybar не найдена"
    fi
}

# Настройка systemd служб
setup_services() {
    info "Настройка systemd служб..."
    
    # Включение NetworkManager (если используется)
    if systemctl list-unit-files | grep -q NetworkManager.service; then
        sudo systemctl enable NetworkManager.service 2>/dev/null || warning "Не удалось включить NetworkManager"
        sudo systemctl start NetworkManager.service 2>/dev/null || warning "Не удалось запустить NetworkManager"
    fi
    
    success "Службы настроены"
}

# Настройка Nix configuration.nix
setup_nix_config() {
    info "Настройка глобальной конфигурации NixOS..."
    
    if [ -f "$SCRIPT_DIR/configuration.nix" ]; then
        NIX_CONFIG_PATH="/etc/nixos/configuration.nix"
        
        # Создание бэкапа текущей конфигурации
        if [ -f "$NIX_CONFIG_PATH" ]; then
            sudo cp "$NIX_CONFIG_PATH" "${NIX_CONFIG_PATH}.backup-$(date +%Y%m%d-%H%M%S)"
            info "Создан бэкап текущей конфигурации"
        fi
        
        # Копирование новой конфигурации
        sudo cp "$SCRIPT_DIR/configuration.nix" "$NIX_CONFIG_PATH"
        success "Конфигурация NixOS скопирована в $NIX_CONFIG_PATH"
        
        # Пересборка системы
        info "Пересборка NixOS конфигурации..."
        sudo nixos-rebuild switch
    else
        warning "Файл configuration.nix не найден, пропускаю настройку глобальной конфигурации"
    fi
}

# Создание автозапуска Hyprland
setup_autostart() {
    info "Настройка автозапуска Hyprland..."
    
    # Создание .xinitrc если его нет
    if [ ! -f "$HOME/.xinitrc" ]; then
        cat > "$HOME/.xinitrc" << EOF
#!/usr/bin/env bash
exec Hyprland
EOF
        chmod +x "$HOME/.xinitrc"
        success "Создан .xinitrc для запуска Hyprland"
    fi
    
    # Создание .zprofile для запуска Hyprland при входе в tty
    if [ ! -f "$HOME/.zprofile" ]; then
        cat > "$HOME/.zprofile" << EOF
if [ -z \$DISPLAY ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
EOF
        success "Создан .zprofile для автозапуска Hyprland"
    fi
}

# Проверка наличия конфигураций
check_configs() {
    info "Проверка наличия конфигурационных файлов..."
    
    missing_files=()
    
    [ ! -f "$SCRIPT_DIR/configuration.nix" ] && missing_files+=("configuration.nix")
    [ ! -f "$SCRIPT_DIR/hyprland.conf" ] && missing_files+=("hyprland.conf")
    [ ! -f "$SCRIPT_DIR/hyprpaper.conf" ] && missing_files+=("hyprpaper.conf")
    [ ! -d "$SCRIPT_DIR/rofi" ] && missing_files+=("rofi/")
    [ ! -d "$SCRIPT_DIR/waybar" ] && missing_files+=("waybar/")
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        warning "Не найдены следующие файлы/директории:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        echo "Установка продолжится с доступными файлами."
    else
        success "Все конфигурационные файлы найдены"
    fi
}

# Основная функция
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}   NixBliss Установочный скрипт${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Проверки
    check_root
    check_nixos
    check_configs
    
    # Установка
    copy_configs
    setup_services
    setup_nix_config
    setup_autostart
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   Установка завершена успешно!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Что сделано:"
    echo "1. Скопированы конфигурационные файлы в ~/.config/"
    echo "2. Настроены systemd службы"
    echo "3. Обновлена глобальная конфигурация NixOS"
    echo "4. Настроен автозапуск Hyprland"
    echo ""
    
    if [ -f "$SCRIPT_DIR/configuration.nix" ]; then
        echo "Конфигурация NixOS была обновлена. Пакеты установятся автоматически."
        echo "Проверьте, что в вашем configuration.nix есть все необходимые пакеты:"
        echo "  - hyprland"
        echo "  - hyprpaper"
        echo "  - rofi-wayland"
        echo "  - waybar"
        echo "  - и другие зависимости"
    else
        echo "Файл configuration.nix не найден. Установите пакеты вручную:"
        echo "  sudo nix-env -iA nixos.hyprland nixos.hyprpaper nixos.rofi-wayland nixos.waybar"
    fi
    
    echo ""
    echo "Перезагрузите систему для применения всех изменений:"
    echo "  sudo reboot"
    echo ""
    echo "После перезагрузки:"
    echo "1. Войдите в tty1 (Ctrl+Alt+F1)"
    echo "2. Hyprland запустится автоматически"
    echo "3. Или выберите Hyprland в меню входа (если используете дисплейный менеджер)"
}

# Запуск основной функции
main "$@"
