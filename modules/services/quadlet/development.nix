let
  networkName = "development";
in
{
  flake.modules.nixos.quadlet-development =
    { config, lib, ... }:
    let
      inherit (config.virtualisation.quadlet) networks;
      anyDevEnabled = lib.any (c: config.modules.containers.${c}) [
        "jenkins"
        "forgejo"
      ];
    in
    {
      systemd.tmpfiles.rules = [
        "d ${config.utils.dataDir "jenkins"} 0755 root root -"
        "d ${config.utils.dataDir "gitea"} 0755 root root -"
      ];

      modules.containers = {
        jenkins = lib.mkDefault true;
        forgejo = lib.mkDefault true;
      };

      virtualisation.quadlet = {
        networks.${networkName} = lib.mkIf anyDevEnabled {
          networkConfig = {
            subnets = [ "172.23.0.0/16" ];
            disableDns = true;
          };
        };

        containers.jenkins = lib.mkIf config.modules.containers.jenkins (
          config.utils.mkContainer {
            containerConfig = {
              image = "jenkins/jenkins:lts-jdk21";
              networks = [ networks.${networkName}.ref ];
              ip = "172.23.0.2";
              volumes = [
                "${config.utils.dataDir "jenkins"}:/var/jenkins_home"
              ];
            };
          }
        );

        containers.forgejo = lib.mkIf config.modules.containers.forgejo (
          config.utils.mkContainer {
            containerConfig = {
              image = "codeberg.org/forgejo/forgejo:15";
              environments = {
                USER_UID = "1000";
                USER_GID = "1000";
              };
              networks = [ networks.${networkName}.ref ];
              ip = "172.23.0.3";
              publishPorts = [ "222:22" ];
              volumes = [
                "${config.utils.dataDir "gitea"}:/data"
                "/etc/localtime:/etc/localtime:ro"
              ];
            };
          }
        );
      };
    };

  flake.modules.nixos.gateway =
    { config, lib, ... }:
    {
      modules.gateway.services = {
        development-jenkins = lib.mkIf config.modules.containers.jenkins {
          name = "Jenkins";
          domainName = "jenkins";
          addr = "172.23.0.2:8080";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jenkins.png";
          category = "Development";
        };

        development-forgejo = lib.mkIf config.modules.containers.forgejo {
          name = "Forgejo";
          domainName = "git";
          addr = "172.23.0.3:3000";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/forgejo.png";
          category = "Development";
        };
      };
    };
}
