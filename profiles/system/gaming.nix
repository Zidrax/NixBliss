{ config, lib, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    gamemode.enable = true;
  };

  networking.firewall = {
    allowedUDPPortRanges = [
      { from = 27000; to = 27020; }
      { from = 27021; to = 27050; }
    ];
    allowedUDPPorts = [ 27031 27036 4380 ];
  };
}

