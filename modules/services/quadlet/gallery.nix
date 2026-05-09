let
  networkName = "gallery";
  gallerySrc = fetchGit {
    url = "https://github.com/wongcallum/gallery.callumwong.com.git";
    ref = "revival";
    rev = "6a573fd405a98bbe24735da92efa118511ad6cc3";
  };
in
{ inputs, lib, ... }:
{
  flake.modules.nixos.quadlet-gallery =
    { config, ... }:
    let
      inherit (config.virtualisation.quadlet) networks builds;
    in
    {
      imports = [ inputs.quadlet-nix.nixosModules.quadlet ];

      systemd.tmpfiles.rules = [
        "d ${config.utils.dataDir "gallery-db"} 0755 root root -"
      ];

      modules.containers = {
        gallery = lib.mkDefault true;
      };

      sops.secrets."docker/gallery_env" = {
        owner = "root";
        group = "root";
        mode = "0440";
      };

      virtualisation.quadlet = {
        networks.${networkName} = {
          networkConfig = {
            subnets = [ "172.24.0.0/16" ];
            disableDns = true;
          };
        };

        builds.gallery-app = lib.mkIf config.modules.containers.gallery {
          buildConfig = {
            workdir = "${gallerySrc}";
          };
        };

        builds.gallery-migrate = lib.mkIf config.modules.containers.gallery {
          buildConfig = {
            workdir = "${gallerySrc}";
            target = "migrator";
          };
        };

        containers.gallery-db = lib.mkIf config.modules.containers.gallery (
          config.utils.mkContainer {
            containerConfig = {
              image = "postgres:18-alpine";
              environments = {
                POSTGRES_USER = "postgres";
                POSTGRES_PASSWORD = "postgres";
                POSTGRES_DB = "gallery";
              };
              networks = [ networks.${networkName}.ref ];
              ip = "172.24.0.2";
              volumes = [
                "${config.utils.dataDir "gallery-db"}:/var/lib/postgresql"
              ];
              healthCmd = "pg_isready -U postgres -d gallery";
              healthInterval = "5s";
              healthTimeout = "5s";
              healthRetries = 5;
              healthStartPeriod = "10s";
              notify = "healthy";
            };
          }
        );

        containers.gallery-migrate = lib.mkIf config.modules.containers.gallery {
          containerConfig = {
            image = builds.gallery-migrate.ref;
            environments = {
              DATABASE_URL = "postgresql://postgres:postgres@172.24.0.2:5432/gallery";
              SKIP_ENV_VALIDATION = "1";
            };
            networks = [ networks.${networkName}.ref ];
            ip = "172.24.0.3";
          };
          unitConfig = {
            Requires = [ "gallery-db.service" ];
            After = [ "gallery-db.service" ];
          };
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "no";
          };
        };

        containers.gallery-app = lib.mkIf config.modules.containers.gallery {
          containerConfig = {
            image = builds.gallery-app.ref;
            environmentFiles = [ config.sops.secrets."docker/gallery_env".path ];
            environments = {
              DATABASE_URL = "postgresql://postgres:postgres@172.24.0.2:5432/gallery";
            };
            networks = [ networks.${networkName}.ref ];
            ip = "172.24.0.4";
          };
          unitConfig = {
            Requires = [
              "gallery-db.service"
              "gallery-migrate.service"
            ];
            After = [
              "gallery-db.service"
              "gallery-migrate.service"
            ];
          };
          serviceConfig = {
            Restart = "always";
            RestartSec = "10";
          };
        };
      };
    };

  flake.modules.nixos.gateway =
    { config, lib, ... }:
    {
      modules.gateway.services = {
        gallery = lib.mkIf config.modules.containers.gallery {
          name = "Gallery";
          domainName = "gallery";
          addr = "172.24.0.4:3000";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/photoprism.png";
          category = "Personal";
        };
      };
    };
}
