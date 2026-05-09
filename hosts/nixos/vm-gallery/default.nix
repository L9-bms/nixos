{ config, microvmLib, ... }:
{
  flake.modules.nixos."hosts/nixos/vm-gallery" = {
    imports = [
      (microvmLib.mkGuestModule {
        n = 1;
        hostname = "vm-gallery";
      })
    ]
    ++ (with config.flake.modules.nixos; [
      persistence
      sops

      ssh
      tailscale

      quadlet-gallery
    ]);

    system.stateVersion = "25.11";

    environment.persistence."/persist".directories = [
      "/var/lib/containers"
    ];

    virtualisation.quadlet.containers.gallery-app.containerConfig.publishPorts = [ "3000:3000" ];

    users.users.root.password = "password";
  };
}
