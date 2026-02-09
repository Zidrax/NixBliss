#!/bin/sh

# --- 1. СБОР ДАННЫХ ---

# Сенса: -1..1 -> 0..1
S_REAL=$(hyprctl getoption input:sensitivity | grep "float:" | awk '{print $2}')
S_USER=$(awk -v val="$S_REAL" 'BEGIN {print (val + 1) / 2}')

# Яркость: %
B_VAL=$(brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d %)
[ -z "$B_VAL" ] && B_VAL="N/A"

# Звук: % (через pamixer, так надежнее)
VOL_VAL=$(pamixer --get-volume)
MIC_VAL=$(pamixer --default-source --get-volume)

# --- 2. ГЛАВНОЕ МЕНЮ ---
# Формат: "Иконка  Название (Текущее значение)"

# Опции меню
OPT_WIFI="  WiFi Menu"
OPT_BT="  Bluetooth"
OPT_SENS="  Sensitivity ($S_USER)"
OPT_BRIGHT="  Brightness ($B_VAL%)"
OPT_VOL="  Volume ($VOL_VAL%)"
OPT_MIC="  Mic Volume ($MIC_VAL%)"

# Показываем Rofi (высота 500px берется из твоего глобального конфига)
CHOICE=$(echo -e "$OPT_WIFI\n$OPT_BT\n$OPT_VOL\n$OPT_MIC\n$OPT_BRIGHT\n$OPT_SENS" | rofi -dmenu -p "Settings")

# --- 3. ЛОГИКА ---

case "$CHOICE" in
    "$OPT_WIFI")
        # Запускает networkmanager_dmenu (если установлен) или nmtui в терминале
        if command -v networkmanager_dmenu >/dev/null; then
            networkmanager_dmenu
        else
            kitty -e nmtui
        fi
        ;;

    "$OPT_BT")
        # Запускает графический менеджер Bluetooth
        blueman-manager
        ;;

    "$OPT_SENS")
        VAL=$(echo "" | rofi -dmenu -p "Sens (0 - 1)" -theme-str 'listview { enabled: false; }')
        if [ -n "$VAL" ]; then
            NEW_SENS=$(awk -v val="$VAL" 'BEGIN {print val * 2 - 1}')
            hyprctl keyword input:sensitivity "$NEW_SENS"
        fi
        ;;

    "$OPT_BRIGHT")
        VAL=$(echo "" | rofi -dmenu -p "Brightness (0 - 100)" -theme-str 'listview { enabled: false; }')
        if [ -n "$VAL" ]; then
            brightnessctl set "$VAL"%
        fi
        ;;

    "$OPT_VOL")
        VAL=$(echo "" | rofi -dmenu -p "Volume (0 - 100)" -theme-str 'listview { enabled: false; }')
        if [ -n "$VAL" ]; then
            pamixer --set-volume "$VAL"
        fi
        ;;

    "$OPT_MIC")
        VAL=$(echo "" | rofi -dmenu -p "Mic Level (0 - 100)" -theme-str 'listview { enabled: false; }')
        if [ -n "$VAL" ]; then
            pamixer --default-source --set-volume "$VAL"
        fi
        ;;
esac
