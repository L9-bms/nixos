{ config, microvmLib, ... }:
{
  flake.modules.nixos."hosts/nixos/vm-jenkins" =
    { pkgs, ... }:
    {
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

      microvm.volumes = [
        {
          mountPoint = "/var/lib/docker";
          image = "/persist/microvms/vm-jenkins-docker.img";
          size = 20 * 1024;
          fsType = "ext4";
        }
      ];

      system.stateVersion = "25.11";

      environment.persistence."/persist".directories = [
        "/var/lib/jenkins"
      ];

      networking.firewall.allowedTCPPorts = [ 8080 ];

      services.jenkins = {
        enable = true;
        listenAddress = "0.0.0.0";
        extraJavaOptions = [
          "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
          "-Djava.net.preferIPv4Stack=true"
        ];
        packages = with pkgs; [
          git
          bash
          coreutils
          unzip
          gnutar
          gzip
          docker-client
        ];
      };

      virtualisation.docker.enable = true;
      users.users.jenkins.extraGroups = [ "docker" ];

      users.users.root.password = "password";
    };
}
