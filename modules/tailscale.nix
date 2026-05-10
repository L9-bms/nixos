{ lib, ... }:
{
  flake.modules.nixos.tailscale =
    { config, ... }:
    {
      modules.tailscale.enable = lib.mkDefault true;

      services.tailscale.enable = true;
      services.tailscale.useRoutingFeatures = "server";

      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
    };

  flake.modules.nixos.persistence =
    { config, ... }:
    {
      environment.persistence.${config.modules.persistence.persistDir}.directories =
        lib.mkIf config.modules.tailscale.enable
          [
            "/var/lib/tailscale"
          ];
    };
}
