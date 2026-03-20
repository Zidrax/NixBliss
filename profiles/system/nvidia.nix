{ config, lib, pkgs, ... }:
{
  # --- Аппаратное обеспечение ---
  hardware = {
    cpu.intel.updateMicrocode = true;
    # NVIDIA
    nvidia = {
      open = true; # ВАЖНО - для старых карт поменять на false 
      modesetting.enable = true;
      forceFullCompositionPipeline = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    
    # Графика
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        intel-media-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    
    # Графический планшет
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

}
