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

# Определяем реального пользователя и пути
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME="$(eval echo ~$REAL_USER)"
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

# Пути
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$REAL_HOME"
CONFIG_DIR="$REAL_HOME/.config"

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

# Создание директории для обоев с правильными правами
create_wallpaper_dir() {
    info "Создание директории для обоев..."
    
    # Создаем директорию с правильными правами с самого начала
    mkdir -p "$HOME_DIR/Pictures/Wallpaper"
    
    # Устанавливаем правильного владельца (пользователь:группа)
    if [ -n "$SUDO_USER" ]; then
        # Получаем основную группу пользователя
        USER_GROUP=$(id -gn "$REAL_USER")
        chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/Pictures" 2>/dev/null || {
            # Если не удалось изменить владельца, пробуем через sudo
            sudo chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/Pictures"
        }
    else
        # Если скрипт запущен без sudo, владелец уже правильный
        USER_GROUP=$(id -gn "$REAL_USER")
        chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/Pictures" 2>/dev/null || true
    fi
    
    # Устанавливаем правильные права (755 - владелец может писать, остальные только читать)
    chmod 755 "$HOME_DIR/Pictures" 2>/dev/null || sudo chmod 755 "$HOME_DIR/Pictures"
    chmod 755 "$HOME_DIR/Pictures/Wallpaper" 2>/dev/null || sudo chmod 755 "$HOME_DIR/Pictures/Wallpaper"
    
    success "Директория для обоев создана: $HOME_DIR/Pictures/Wallpaper"
    info "Права директории:"
    ls -la "$HOME_DIR/Pictures/" | grep Wallpaper
}

# Вывод информации о путях для отладки
debug_paths() {
    info "=== Отладка путей ==="
    info "Реальный пользователь: $REAL_USER"
    info "Домашняя директория: $REAL_HOME"
    info "Директория скрипта: $SCRIPT_DIR"
    info "Целевая конфиг директория: $CONFIG_DIR"
    info "Текущий пользователь (shell): $USER"
    info "SUDO_USER: ${SUDO_USER:-не установлен}"
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
    info "Копирование конфигурационных файлов в $CONFIG_DIR..."
    
    # Создание директорий если их нет
    mkdir -p "$CONFIG_DIR/hypr"
    mkdir -p "$CONFIG_DIR/rofi"
    mkdir -p "$CONFIG_DIR/waybar"
    
    # Устанавливаем правильного владельца для директорий
    if [ -n "$SUDO_USER" ]; then
        chown -R "$REAL_USER:$USER_GROUP" "$CONFIG_DIR/hypr" 2>/dev/null || true
        chown -R "$REAL_USER:$USER_GROUP" "$CONFIG_DIR/rofi" 2>/dev/null || true
        chown -R "$REAL_USER:$USER_GROUP" "$CONFIG_DIR/waybar" 2>/dev/null || true
        chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/Pictures" 2>/dev/null || true
    fi
    
    # Копирование hyprland конфигураций
    if [ -f "$SCRIPT_DIR/hyprland.conf" ]; then
        cp "$SCRIPT_DIR/hyprland.conf" "$CONFIG_DIR/hypr/"
        chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null || true
        success "Hyprland конфигурация скопирована в $CONFIG_DIR/hypr/"
    else
        warning "Файл hyprland.conf не найден в $SCRIPT_DIR"
    fi
    
    if [ -f "$SCRIPT_DIR/hyprpaper.conf" ]; then
        cp "$SCRIPT_DIR/hyprpaper.conf" "$CONFIG_DIR/hypr/"
        chown "$REAL_USER:$REAL_USER" "$CONFIG_DIR/hypr/hyprpaper.conf" 2>/dev/null || true
        success "Hyprpaper конфигурация скопирована в $CONFIG_DIR/hypr/"
    else
        warning "Файл hyprpaper.conf не найден в $SCRIPT_DIR"
    fi
    
    # Копирование rofi конфигураций
    if [ -d "$SCRIPT_DIR/rofi" ] && [ -n "$(ls -A "$SCRIPT_DIR/rofi" 2>/dev/null)" ]; then
        cp -r "$SCRIPT_DIR/rofi/"* "$CONFIG_DIR/rofi/"
        if [ -n "$SUDO_USER" ]; then
            chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR/rofi" 2>/dev/null || true
        fi
        success "Rofi конфигурации скопированы в $CONFIG_DIR/rofi/"
    else
        warning "Директория rofi не найдена или пуста в $SCRIPT_DIR"
    fi
    
    # Копирование waybar конфигураций
    if [ -d "$SCRIPT_DIR/waybar" ] && [ -n "$(ls -A "$SCRIPT_DIR/waybar" 2>/dev/null)" ]; then
        cp -r "$SCRIPT_DIR/waybar/"* "$CONFIG_DIR/waybar/"
        if [ -n "$SUDO_USER" ]; then
            chown -R "$REAL_USER:$REAL_USER" "$CONFIG_DIR/waybar" 2>/dev/null || true
        fi
        success "Waybar конфигурации скопированы в $CONFIG_DIR/waybar/"
    else
        warning "Директория waybar не найдена или пуста в $SCRIPT_DIR"
    fi
    
    # Проверка что скопировалось
    info "Проверка скопированных файлов:"
    echo "--- $CONFIG_DIR/hypr/ ---"
    ls -la "$CONFIG_DIR/hypr/" 2>/dev/null || echo "  (пусто или недоступно)"
    echo "--- $CONFIG_DIR/rofi/ ---"
    ls -la "$CONFIG_DIR/rofi/" 2>/dev/null || echo "  (пусто или недоступно)"
    echo "--- $CONFIG_DIR/waybar/ ---"
    ls -la "$CONFIG_DIR/waybar/" 2>/dev/null || echo "  (пусто или недоступно)"
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
    info "Настройка автозапуска Hyprland для пользователя $REAL_USER..."
    
    # Создание .xinitrc если его нет
    if [ ! -f "$REAL_HOME/.xinitrc" ]; then
        cat > "$REAL_HOME/.xinitrc" << EOF
#!/usr/bin/env bash
exec Hyprland
EOF
        chmod +x "$REAL_HOME/.xinitrc"
        chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.xinitrc" 2>/dev/null || true
        success "Создан .xinitrc для запуска Hyprland в $REAL_HOME/.xinitrc"
    else
        info ".xinitrc уже существует, пропускаю"
    fi
    
    # Создание .zprofile для запуска Hyprland при входе в tty
    if [ ! -f "$REAL_HOME/.zprofile" ]; then
        cat > "$REAL_HOME/.zprofile" << EOF
if [ -z \$DISPLAY ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
EOF
        chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.zprofile" 2>/dev/null || true
        success "Создан .zprofile для автозапуска Hyprland в $REAL_HOME/.zprofile"
    else
        info ".zprofile уже существует, пропускаю"
    fi
}

# Проверка наличия конфигураций
check_configs() {
    info "Проверка наличия конфигурационных файлов в $SCRIPT_DIR..."
    
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

# Проверка, куда копируются файлы
verify_copy() {
    info "=== Проверка результатов копирования ==="
    
    echo "Ожидаемые файлы в $CONFIG_DIR/:"
    expected_files=(
        "$CONFIG_DIR/hypr/hyprland.conf"
        "$CONFIG_DIR/hypr/hyprpaper.conf"
        "$CONFIG_DIR/rofi/config.rasi"
        "$CONFIG_DIR/rofi/style.rasi"
        "$CONFIG_DIR/waybar/config"
        "$CONFIG_DIR/waybar/style.css"
    )
    
    for file in "${expected_files[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✓ $(basename "$file")"
        else
            echo "  ✗ $(basename "$file") - не найден"
        fi
    done
    
    # Показываем владельцев файлов
    echo ""
    info "Права доступа и владельцы:"
    for dir in hypr rofi waybar; do
        if [ -d "$CONFIG_DIR/$dir" ]; then
            echo "--- $CONFIG_DIR/$dir/ ---"
            ls -la "$CONFIG_DIR/$dir/" 2>/dev/null | head -10
        fi
    done
}

# Основная функция
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}   NixBliss Установочный скрипт${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Отладка путей
    debug_paths

    # Создание директории для обоев
    create_wallpaper_dir
    
    # Проверки
    check_root
    check_nixos
    check_configs
    
    # Установка
    copy_configs
    setup_services
    setup_nix_config
    setup_autostart
    
    # Проверка результатов
    verify_copy
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   Установка завершена успешно!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Что сделано:"
    echo "1. Конфигурационные файлы скопированы в $CONFIG_DIR/"
    echo "2. Настроены systemd службы"
    echo "3. Обновлена глобальная конфигурация NixOS"
    echo "4. Настроен автозапуск Hyprland для пользователя $REAL_USER"
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
    echo "Проверьте наличие файлов:"
    echo "  ls -la $CONFIG_DIR/hypr/"
    echo "  ls -la $CONFIG_DIR/rofi/"
    echo "  ls -la $CONFIG_DIR/waybar/"
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
