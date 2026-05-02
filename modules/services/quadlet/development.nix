let
  networkName = "development";
in
{
  flake.modules.nixos.quadlet-development =
    { config, ... }:
    let
      inherit (config.virtualisation.quadlet) networks;
    in
    {
      virtualisation.quadlet = {
        networks.${networkName}.networkConfig = {
          subnets = [ "172.23.0.0/16" ];
          disableDns = true;
        };

        containers.jenkins = {
          serviceConfig = {
            Restart = "always";
            RestartSec = "10";
          };
          containerConfig = {
            image = "jenkins/jenkins:lts-jdk21";
            networks = [ networks.${networkName}.ref ];
            ip = "172.23.0.2";
            volumes = [
              "${config.utils.dataDir "jenkins"}:/var/jenkins_home"
            ];
          };
        };

        containers.forgejo = {
          serviceConfig = {
            Restart = "always";
            RestartSec = "10";
          };
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
        };
      };
    };

  flake.modules.nixos.gateway =
    { config, lib, ... }:
    {
      modules.gateway.localServices = lib.mkMerge [
        (lib.optional (lib.hasAttrByPath [ "virtualisation" "quadlet" "containers" "jenkins" ] config) {
          name = "Jenkins";
          domainName = "jenkins";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jenkins.png";
          addr = "172.23.0.2:8080";
          category = "Development";
        })
        (lib.optional (lib.hasAttrByPath [ "virtualisation" "quadlet" "containers" "forgejo" ] config) {
          name = "Forgejo";
          domainName = "git";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/forgejo.png";
          addr = "172.23.0.3:3000";
          category = "Development";
        })
      ];
    };
}
