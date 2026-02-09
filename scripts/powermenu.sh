#!/bin/sh
chosen=$(printf "  Shutdown\n  Reboot\n  Suspend\n  Lock" | rofi -dmenu -p "Power Action" -theme-str 'window {width: 300px;}')

case "$chosen" in
    *Shutdown) systemctl poweroff ;;
    *Reboot) systemctl reboot ;;
    *Suspend) systemctl suspend ;;
    *Lock) hyprlock ;; # Или swaylock, смотря что используешь
esac
