🚀 Гайд по установке NixBliss на новое устройство

1. Подготовка
Временно устанавливаем git в систему:
```Bash
nix-shell -p git
```
2. Клонирование:
```Bash
git clone https://github.com/Zidrax/NixBliss.git ~/dotfiles
cd ~/dotfiles
```

Либо клонирование по ssh:
```bash
git clone git@github.com:Zidrax/NixBliss.git ~/dotfiles
cd ~/dotfiles
```

3. Генерация конфига железа

Сгенерируй файл, специфичный для твоего текущего ПК/ноутбука:
```Bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```


4. Применение конфига

Запусти сборку системы:
```bash
sudo nixos-rebuild switch --flake .#laptop
```
