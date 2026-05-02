{
  flake.modules.nixos.syncthing =
    { config, ... }:
    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        dataDir = config.utils.dataDir "syncthing";
        configDir = config.utils.dataDir "syncthing";
      };
    };

  flake.modules.nixos.gateway =
    { config, lib, ... }:
    {
      services.syncthing.settings.gui.insecureSkipHostcheck = true;

      modules.gateway.localServices = lib.mkMerge [
        (lib.optional config.services.syncthing.enable {
          name = "Syncthing";
          domainName = "syncthing";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/syncthing.png";
          addr = "127.0.0.1:8384";
          category = "Administration";
        })
      ];
    };
}
