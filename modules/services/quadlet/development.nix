let
  networkName = "development";
in
{ inputs, lib, ... }:
{
  flake.modules.nixos.quadlet-development =
    { config, ... }:
    let
      inherit (config.virtualisation.quadlet) networks;
    in
    {
      imports = [ inputs.quadlet-nix.nixosModules.quadlet ];

      systemd.tmpfiles.rules = [
        "d ${config.utils.dataDir "gitea"} 0755 root root -"
      ];

      modules.containers = {
        forgejo = lib.mkDefault true;
      };

      virtualisation.quadlet = {
        networks.${networkName} = {
          networkConfig = {
            subnets = [ "172.23.0.0/16" ];
            disableDns = true;
          };
        };

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
