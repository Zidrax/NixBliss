{ config, lib, pkgs, ... }:
{
  # --- Виртуализация ---
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    
    podman = {
      enable = true;
      dockerCompat = false; # Ставим false, чтобы не конфликтовать с командой 'docker'
    };

    incus.enable = true;
    libvirtd.enable = true;
    # lxc.lxcfs.enable = true;
  };
}
