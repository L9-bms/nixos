{
  flake.modules.nixos.syncthing-user = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "callum";
      dataDir = "/home/callum";
    };
  };
}
