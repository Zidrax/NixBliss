{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "pi" = {
        hostname = "192.168.50.42";
        user = "user";
        # Агент (чтобы ключи для гитхаба с ПК работали на устройсте)
        forwardAgent = true; 

        # Аналог флага -Y (Trusted X11 Forwarding)
        forwardX11 = true;
        forwardX11Trusted = true;
      };
      "*" = {
        # serverAliveInterval = 60;
      };
    };
  };
}

