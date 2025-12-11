#!/usr/bin/env bash

# Установочный скрипт для NixBliss
set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции вывода
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Получаем пользователя и пути
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME="$(eval echo ~$REAL_USER)"
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REAL_HOME/.config"

info "Пользователь: $REAL_USER"
info "Домашняя директория: $REAL_HOME"
info "Конфиг директория: $CONFIG_DIR"

# Проверка root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        info "Запрашиваю sudo..."
        if ! sudo -v; then
            error "Нет прав root"
            exit 1
        fi
    fi
}

# Проверка NixOS
check_nixos() {
    if [ ! -f /etc/NIXOS ]; then
        error "Только для NixOS!"
        exit 1
    fi
}

# Копирование конфигов
copy_configs() {
    info "Копирование конфигурационных файлов в $CONFIG_DIR..."
    
    # Создаем директории с правильными правами
    mkdir -p "$CONFIG_DIR/hypr"
    mkdir -p "$CONFIG_DIR/rofi"
    mkdir -p "$CONFIG_DIR/waybar"
    
    # Устанавливаем владельца
    if [ -n "$SUDO_USER" ]; then
        chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR"
    fi
    
    # Копируем с проверкой
    if [ -f "$SCRIPT_DIR/hyprland.conf" ]; then
        cp -v "$SCRIPT_DIR/hyprland.conf" "$CONFIG_DIR/hypr/"
        success "Hyprland конфигурация скопирована"
    else
        warning "Файл hyprland.conf не найден"
    fi
    
    if [ -f "$SCRIPT_DIR/hyprpaper.conf" ]; then
        cp -v "$SCRIPT_DIR/hyprpaper.conf" "$CONFIG_DIR/hypr/"
        success "Hyprpaper конфигурация скопирована"
    else
        warning "Файл hyprpaper.conf не найден"
    fi
    
    if [ -d "$SCRIPT_DIR/rofi" ]; then
        cp -rv "$SCRIPT_DIR/rofi/"* "$CONFIG_DIR/rofi/"
        success "Rofi конфигурации скопированы"
    else
        warning "Директория rofi не найдена"
    fi
    
    if [ -d "$SCRIPT_DIR/waybar" ]; then
        cp -rv "$SCRIPT_DIR/waybar/"* "$CONFIG_DIR/waybar/"
        success "Waybar конфигурации скопированы"
    else
        warning "Директория waybar не найдена"
    fi
    
    # Проверяем что скопировалось
    info "Проверка скопированных файлов:"
    ls -la "$CONFIG_DIR/hypr/" 2>/dev/null || echo "Нет hypr директории"
    ls -la "$CONFIG_DIR/rofi/" 2>/dev/null || echo "Нет rofi директории"
    ls -la "$CONFIG_DIR/waybar/" 2>/dev/null || echo "Нет waybar директории"
}

# Основная функция
main() {
    echo -e "${BLUE}=== NixBliss Установщик ===${NC}"
    
    check_root
    check_nixos
    copy_configs
    
    echo -e "${GREEN}=== Установка завершена! ===${NC}"
    echo "Конфиги скопированы в: $CONFIG_DIR"
    echo "Проверьте: ls -la $CONFIG_DIR/"
}

main "$@"
