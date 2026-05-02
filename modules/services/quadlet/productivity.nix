{
  flake.modules.nixos.quadlet-productivity =
    { config, ... }:
    let
      inherit (config.virtualisation.quadlet) networks builds;
      copilotApiSrc = fetchGit {
        url = "https://github.com/caozhiyuan/copilot-api.git";
        rev = "c4ab3b779066b9a176e8e73351f4b23da047e8e7";
      };
    in
    {
      virtualisation.quadlet = {
        networks.ai.networkConfig = {
          subnets = [ "172.22.0.0/16" ];
          disableDns = true;
        };

        containers.ai-searxng = {
          serviceConfig = {
            Restart = "always";
            RestartSec = "10";
          };
          containerConfig = {
            image = "searxng/searxng:latest";
            volumes = [ "${config.utils.dataDir "searxng"}:/etc/searxng:rw" ];
            networks = [ networks.ai.ref ];
            ip = "172.22.0.3";
            dropCapabilities = [ "ALL" ];
            addCapabilities = [
              "CHOWN"
              "SETGID"
              "SETUID"
              "DAC_OVERRIDE"
            ];
          };
        };

        containers.ai-openwebui = {
          serviceConfig = {
            Restart = "always";
            RestartSec = "10";
          };
          containerConfig = {
            image = "ghcr.io/open-webui/open-webui:main-slim";
            environments = {
              ENABLE_RAG_WEB_SEARCH = "True";
              RAG_WEB_SEARCH_ENGINE = "searxng";
              RAG_WEB_SEARCH_RESULT_COUNT = "3";
              RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "10";
              SEARXNG_QUERY_URL = "http://172.22.0.3:8080/search?q=<query>";
              WEBUI_AUTH = "False";
            };
            networks = [ networks.ai.ref ];
            ip = "172.22.0.2";
            publishPorts = [ "8088:8080" ]; # keep here for dad
            volumes = [
              "${config.utils.dataDir "open-webui"}:/app/backend/data"
            ];
          };
        };

        containers.ai-copilot-api.containerConfig = {
          image = builds.copilot-api.ref;
          networks = [ networks.ai.ref ];
          ip = "172.22.0.4";
          publishPorts = [ "4141:4141" ];
          volumes = [
            "${config.utils.dataDir "copilot-api"}:/root/.local/share/copilot-api"
          ];
        };
        builds.copilot-api.buildConfig = {
          workdir = "${copilotApiSrc}";
        };
      };

      sops.secrets."docker/silverbullet_env" = {
        owner = "root";
        group = "root";
        mode = "0440";
      };

      virtualisation.quadlet.containers.silverbullet = {
        serviceConfig = {
          Restart = "always";
          RestartSec = "10";
        };
        containerConfig = {
          image = "ghcr.io/silverbulletmd/silverbullet:latest";
          environmentFiles = [ config.sops.secrets."docker/silverbullet_env".path ];
          publishPorts = [ "3000:3000" ];
          volumes = [
            "${config.utils.dataDir "silverbullet"}:/space"
          ];
        };
      };
    };

  flake.modules.nixos.gateway =
    { config, lib, ... }:
    {
      modules.gateway.localServices = lib.mkMerge [
        (lib.optional (lib.hasAttrByPath [ "virtualisation" "quadlet" "containers" "ai-openwebui" ] config)
          {
            name = "OpenWebUI";
            domainName = "chat";
            iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/open-webui.png";
            addr = "172.22.0.2:8080";
            category = "Productivity";
          }
        )
        (lib.optional (lib.hasAttrByPath [ "virtualisation" "quadlet" "containers" "ai-copilot" ] config) {
          name = "Copilot API";
          domainName = "copilot";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-copilot.png";
          addr = "172.22.0.4:4141";
          category = "Productivity";
        })
        (lib.optional (lib.hasAttrByPath [ "virtualisation" "quadlet" "containers" "silverbullet" ] config)
          {
            name = "SilverBullet";
            domainName = "notes";
            iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/silverbullet.png";
            addr = "127.0.0.1:3000";
            category = "Productivity";
          }
        )
        (lib.optional (lib.hasAttrByPath [ "virtualisation" "quadlet" "containers" "ai-searxng" ] config) {
          name = "SearXNG";
          domainName = "search";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/searxng.png";
          addr = "172.22.0.3:8080";
          hidden = true;
        })
      ];
    };
}
