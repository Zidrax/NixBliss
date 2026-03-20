{ hostname, ... }:

{
  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Твои алиасы
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake ~/dotfiles#${hostname}";
      llama3 = "ollama run llama3";
      phone = "scrcpy --video-codec=h264 --video-bit-rate=16M --audio-codec=opus --audio-buffer=0 --video-buffer=0 --stay-awake --power-off-on-close";
      # CTF = "nix-shell ~/dotfiles/shells/ctf-shell.nix --run zsh";
      discord = "NIXPKGS_ALLOW_UNFREE=1 nix-shell -p discord --run 'discord > /dev/null 2>&1 & disown'";
    };

    initContent = ''
      export ZSH_DISABLE_COMPFIX="true"
      zstyle ':completion:*:*:*:*' ignored-patterns '*.lock' 
      function gcommit() {
        git diff --cached | ollama run llama3 "Ты — генератор git commit сообщений. Проанализируй этот diff и напиши ТОЛЬКО сообщение коммита. РОВНО ПО ШАБЛОНУ gcmsg "сам комит" (ковычки обязательны). Без лишних слов."
      }

      # Умная функция для CTF-контейнера
      CTF() {
        # Фикс белого окна Java в Hyprland
        export _JAVA_AWT_WM_NONREPARENTING=1
        
        # Если аргументов нет — просто заходим
        if [[ $# -eq 0 ]]; then
          distrobox enter ctf-box
          return
        fi

        # Цикл по всем аргументам
        for arg in "$@"; do
          case "$arg" in
            --create)
              echo "🛠️ Создаю изолированный контейнер ctf-box..."
              mkdir -p ~/distrobox/ctf
              distrobox create --image kalilinux/kali-rolling --name ctf-box --home ~/distrobox/ctf
              ;;
            --setup)
              echo "🚀 Установка арсенала (тихий режим)..."
              # Основной софт + Java для Гидры
              distrobox enter ctf-box -- sh -c "sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt install -y \
                kali-linux-headless zsh nmap netcat-openbsd socat metasploit-framework aircrack-ng responder \
                theharvester gospider sqlmap ffuf feroxbuster nikto wpscan commix wireshark \
                netexec evil-winrm ghidra openjdk-21-jdk radare2 gdb python3-pwntools ltrace strace \
                hashcat john binwalk libimage-exiftool-perl steghide pngcheck \
                sonic-visualiser ffmpeg audacity python3-pip ruby-full build-essential npm"

              echo "💎 Доустанавливаю zsteg и sherlock..."
              distrobox enter ctf-box -- sh -c "sudo gem install zsteg && sudo pip3 install sherlock-project --break-system-packages"

              echo "🖌️ Фикс 'белого окна' внутри контейнера..."
              echo 'export _JAVA_AWT_WM_NONREPARENTING=1' >> ~/distrobox/ctf/.zshrc

              echo "🔐 Автоматический фикс прав для $USER..."
              sudo mkdir -p ~/distrobox/ctf/.config/nvim
              sudo chown -R ''${USER}:users ~/distrobox/ctf

              echo "📦 Настройка Neovim..."
              # Копируем созданный портативный конфиг
              cp ~/dotfiles/home/terminal/nvim/portable.lua ~/distrobox/ctf/.config/nvim/init.lua

              echo "✅ Neovim готов! При первом запуске он сам скачает плагины."
              
              
              echo "✅ Все настроено!"
              ;;
            --stop)
              distrobox stop ctf-box ;;
            --restart)
              distrobox stop ctf-box && distrobox enter ctf-box ;;
            --rm)
              distrobox rm ctf-box ;;
            --help|-h)
              echo -e "💀 \033[1;31mCTF ARSENAL\033[0m 💀"
              echo "Использование: CTF --create --setup"
              ;;
          esac
        done
      }

      # --- Индикатор CTF режима (Справа в терминале) ---
      if [[ -n "$CTF_MODE" ]]; then
        # RPROMPT="%F{red}💀 CTF%f" 

      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "python" "docker"];
      theme = "robbyrussell";
    };
  };

  # Kitty
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.8"; # Уровень прозрачности (от 0.0 до 1.0)
      dynamic_background_opacity = true; # Позволяет менять прозрачность на лету
    };
  };
}

