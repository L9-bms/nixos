let
  networkName = "ai";
in
{
  flake.modules.nixos.quadlet-productivity =
    { config, lib, ... }:
    let
      inherit (config.virtualisation.quadlet) networks builds;
      copilotApiSrc = fetchGit {
        url = "https://github.com/caozhiyuan/copilot-api.git";
        rev = "c4ab3b779066b9a176e8e73351f4b23da047e8e7";
      };
    in
    {
      systemd.tmpfiles.rules = [
        "d ${config.utils.dataDir "searxng"} 0755 root root -"
        "d ${config.utils.dataDir "open-webui"} 0755 root root -"
        "d ${config.utils.dataDir "copilot-api"} 0755 root root -"
        "d ${config.utils.dataDir "langflow"} 0755 root root -"
        "d ${config.utils.dataDir "silverbullet"} 0755 root root -"
      ];

      modules.containers = {
        ai-searxng = lib.mkDefault true;
        ai-openwebui = lib.mkDefault true;
        ai-copilot-api = lib.mkDefault true;
        ai-langflow = lib.mkDefault true;
        silverbullet = lib.mkDefault true;
      };

      virtualisation.quadlet = {
        networks.${networkName} = {
          networkConfig = {
            subnets = [ "172.22.0.0/16" ];
            disableDns = true;
          };
        };

        containers.ai-searxng = lib.mkIf config.modules.containers.ai-searxng (
          config.utils.mkContainer {
            containerConfig = {
              image = "searxng/searxng:latest";
              volumes = [ "${config.utils.dataDir "searxng"}:/etc/searxng:rw" ];
              networks = [ networks.${networkName}.ref ];
              ip = "172.22.0.3";
              dropCapabilities = [ "ALL" ];
              addCapabilities = [
                "CHOWN"
                "SETGID"
                "SETUID"
                "DAC_OVERRIDE"
              ];
            };
          }
        );

        containers.ai-openwebui = lib.mkIf config.modules.containers.ai-openwebui (
          config.utils.mkContainer {
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
              networks = [ networks.${networkName}.ref ];
              ip = "172.22.0.2";
              publishPorts = [ "8088:8080" ]; # keep here for dad
              volumes = [
                "${config.utils.dataDir "open-webui"}:/app/backend/data"
              ];
            };
          }
        );

        containers.ai-copilot-api = lib.mkIf config.modules.containers.ai-copilot-api {
          containerConfig = {
            image = builds.copilot-api.ref;
            networks = [ networks.${networkName}.ref ];
            ip = "172.22.0.4";
            publishPorts = [ "4141:4141" ];
            volumes = [
              "${config.utils.dataDir "copilot-api"}:/root/.local/share/copilot-api"
            ];
          };
        };

        containers.ai-langflow = lib.mkIf config.modules.containers.ai-langflow (
          config.utils.mkContainer {
            containerConfig = {
              image = "langflowai/langflow:latest";
              networks = [ networks.${networkName}.ref ];
              ip = "172.22.0.5";
              volumes = [
                "${config.utils.dataDir "langflow"}:/app/langflow"
              ];
            };
          }
        );

        builds.copilot-api = lib.mkIf config.modules.containers.ai-copilot-api {
          buildConfig = {
            workdir = "${copilotApiSrc}";
          };
        };
      };

      sops.secrets."docker/silverbullet_env" = {
        owner = "root";
        group = "root";
        mode = "0440";
      };

      virtualisation.quadlet.containers.silverbullet = lib.mkIf config.modules.containers.silverbullet (
        config.utils.mkContainer {
          containerConfig = {
            image = "ghcr.io/silverbulletmd/silverbullet:latest";
            healthInterval = "disable";
            environmentFiles = [ config.sops.secrets."docker/silverbullet_env".path ];
            publishPorts = [ "3000:3000" ];
            volumes = [
              "${config.utils.dataDir "silverbullet"}:/space"
            ];
          };
        }
      );
    };

  flake.modules.nixos.gateway =
    { config, lib, ... }:
    {
      modules.gateway.services = {
        productivity-openwebui = lib.mkIf config.modules.containers.ai-openwebui {
          name = "OpenWebUI";
          domainName = "chat";
          addr = "172.22.0.2:8080";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/open-webui.png";
          category = "Productivity";
        };

        productivity-copilot-api = lib.mkIf config.modules.containers.ai-copilot-api {
          name = "Copilot API";
          domainName = "copilot";
          addr = "172.22.0.4:4141";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-copilot.png";
          category = "Productivity";
        };

        productivity-silverbullet = lib.mkIf config.modules.containers.silverbullet {
          name = "SilverBullet";
          domainName = "notes";
          addr = "127.0.0.1:3000";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/silverbullet.png";
          category = "Productivity";
        };

        productivity-searxng = lib.mkIf config.modules.containers.ai-searxng {
          name = "SearXNG";
          domainName = "search";
          addr = "172.22.0.3:8080";
          hidden = true;
        };

        productivity-langflow = lib.mkIf config.modules.containers.ai-langflow {
          name = "Langflow";
          domainName = "langflow";
          addr = "172.22.0.5:7860";
          iconUrl = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/langflow.png";
          category = "Productivity";
        };
      };
    };
}
