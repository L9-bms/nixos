{ config, microvmLib, ... }:
{
  flake.modules.nixos."hosts/nixos/vm-jenkins" = {
    imports = [
      (microvmLib.mkGuestModule {
        n = 2;
        hostname = "vm-jenkins";
      })
    ]
    ++ (with config.flake.modules.nixos; [
      persistence
      sops

      ssh
    ]);

    system.stateVersion = "25.11";

    environment.persistence."/persist".directories = [
      "/var/lib/jenkins"
      "/var/lib/docker"
    ];

    networking.firewall.allowedTCPPorts = [ 8080 ];

    services.jenkins = {
      enable = true;
      listenAddress = "0.0.0.0";
    };

    virtualisation.docker.enable = true;

    users.users.jenkins.extraGroups = [ "docker" ];

    users.users.root.password = "password";
  };
}
