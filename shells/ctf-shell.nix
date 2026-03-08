{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  ctf-help = pkgs.writeShellScriptBin "ctf-help" ''
    echo -e "\n\033[1;31m💀 АРСЕНАЛ CTF-РЕЖИМА (KALI EDITION) 💀\033[0m\n"
    
    echo -e "\033[1;33m🌐 Сеть, Wi-Fi и Разведка\033[0m"
    echo -e "  \033[1;32mnmap\033[0m         - Классический сканер портов и сети"
    echo -e "  \033[1;32mrustscan\033[0m     - Ультрабыстрый сканер портов"
    echo -e "  \033[1;32mnc\033[0m / \033[1;32msocat\033[0m   - Швейцарские ножи для сети"
    echo -e "  \033[1;32mmsfconsole\033[0m   - Metasploit Framework"
    echo -e "  \033[1;32maircrack-ng\033[0m  - Набор для аудита Wi-Fi сетей"
    echo -e "  \033[1;32mresponder\033[0m    - Перехват LLMNR/NBT-NS (кража хэшей в локалке)\n"

    echo -e "\033[1;33m👁️ OSINT (Открытые источники)\033[0m"
    echo -e "  \033[1;32msherlock\033[0m     - Поиск никнеймов по всем соцсетям"
    echo -e "  \033[1;32mtheharvester\033[0m - Сбор email, поддоменов и IP через поисковики"
    echo -e "  \033[1;32mgospider\033[0m     - Веб-паук для сбора ссылок"
    echo -e "  \033[1;32mwaybackurls\033[0m  - Поиск старых ссылок в Архиве Интернета\n"

    echo -e "\033[1;33m🕷️ Веб-уязвимости\033[0m"
    echo -e "  \033[1;32mburpsuite\033[0m    - Прокси для перехвата веб-запросов"
    echo -e "  \033[1;32msqlmap\033[0m       - Автоматическая эксплуатация SQLi"
    echo -e "  \033[1;32mffuf\033[0m         - Фаззер скрытых файлов/параметров"
    echo -e "  \033[1;32mferoxbuster\033[0m  - Мощный фаззер директорий на Rust"
    echo -e "  \033[1;32mnikto\033[0m        - Сканер серверов на уязвимости"
    echo -e "  \033[1;32mwpscan\033[0m       - Сканер уязвимостей WordPress"
    echo -e "  \033[1;32mcommix\033[0m       - Автоматизация Command Injection\n"

    echo -e "\033[1;33m🪟 Windows & Active Directory\033[0m"
    echo -e "  \033[1;32mnetexec\033[0m      - (Замена CrackMapExec и Impacket) Аудит сетей AD"
    echo -e "  \033[1;32mevil-winrm\033[0m   - Оболочка WinRM для пентеста (взлом Windows)\n"

    echo -e "\033[1;33m⚙️ Pwn и Реверс-инжиниринг\033[0m"
    echo -e "  \033[1;32mghidra\033[0m       - Мощный декомпилятор (GUI)"
    echo -e "  \033[1;32mr2\033[0m           - Radare2: консольный реверс"
    echo -e "  \033[1;32mgdb\033[0m          - Отладчик GNU (база для Pwn)"
    echo -e "  \033[1;32mpwntools\033[0m     - Python фреймворк для эксплоитов (команда pwn)"
    echo -e "  \033[1;32mropgadget\033[0m    - Поиск гаджетов для ROP цепочек"
    echo -e "  \033[1;32mltrace\033[0m / \033[1;32mstrace\033[0m - Перехват вызовов библиотек и системы\n"

    echo -e "\033[1;33m🔑 Пароли, Криптография и Форензика\033[0m"
    echo -e "  \033[1;32mhashcat\033[0m      - Быстрый взлом хэшей (GPU)"
    echo -e "  \033[1;32mjohn\033[0m         - John the Ripper (архивы, ключи)"
    echo -e "  \033[1;32mbinwalk\033[0m      - Извлечение вшитых файлов"
    echo -e "  \033[1;32mexiftool\033[0m     - Чтение метаданных файлов"
    echo -e "  \033[1;32msteghide\033[0m     - Стеганография в JPEG/WAV"
    echo -e "  \033[1;32mzsteg\033[0m        - Стеганография в PNG/BMP"
    echo -e "  \033[1;32mpngcheck\033[0m     - Проверка структуры PNG-файлов\n"
    
    echo -e "Вызвать справку: \033[1;36mctf-help\033[0m | Выход: \033[1;31mexit\033[0m\n"
  '';


in
pkgs.mkShell {
  name = "ctf-env";

  packages = with pkgs; [
    ctf-help
    
    # Сеть, Wi-Fi и OSINT
    nmap rustscan netcat-gnu socat metasploit gospider waybackurls aircrack-ng responder
    sherlock theharvester
    
    # Веб
    burpsuite sqlmap ffuf feroxbuster nikto wpscan commix
    
    # AD и Windows (убрали impacket, оставили современные обертки)
    netexec evil-winrm
    
    # Pwn и Реверс
    ghidra radare2 gdb pwntools ropgadget ltrace strace
    
    # Крипта и Форензика
    hashcat john binwalk exiftool steghide zsteg pngcheck
  ];

  shellHook = ''
    export CTF_MODE=1

    echo -e "\n\033[1;31m\tРежим CTF активирован. \033[1;36mctf-help\033[0m для просмотра арсенала.\n"

    # # 1. Запрашиваем ширину терминала у системы
    # cols=$(tput cols 2>/dev/null || echo 80)
    # 
    # # 2. Ширина рамки теперь компактная — 44 символа
    # box_width=44
    # 
    # # 3. Высчитываем отступ слева
    # pad_len=$(( (cols - box_width) / 2 ))
    # [ $pad_len -lt 0 ] && pad_len=0
    # pad=$(printf '%*s' "$pad_len" "")
    # 
    # # 4. Рисуем плотный отцентрированный UI
    # echo -e "\n$pad\033[1;31m╭──────────────────────────────────────────╮\033[0m"
    # echo -e "$pad\033[1;31m│\033[0m         \033[1;31m💀 Режим CTF активирован\033[0m         \033[1;31m│\033[0m"
    # echo -e "$pad\033[1;31m│\033[0m   Введи \033[1;36mctf-help\033[0m для просмотра арсенала  \033[1;31m│\033[0m"
    # echo -e "$pad\033[1;31m╰──────────────────────────────────────────╯\033[0m\n"

    # Задаем путь, где логично хранить словари
    # export SECLISTS=~/wordlists/SecLists
    # 
    # # Проверка, скачаны ли они. Если нет — напоминаем.
    # if [ ! -d "$SECLISTS" ]; then
    #   echo -e "\n\033[1;33m[!] Словари SecLists не найдены в $SECLISTS\033[0m"
    #   echo -e "Рекомендую скачать их руками. Просто выполни:"
    #   echo -e "\033[1;36mmkdir -p ~/wordlists && git clone https://github.com/danielmiessler/SecLists ~/wordlists/SecLists\033[0m\n"
    # fi
    

  '';
}
