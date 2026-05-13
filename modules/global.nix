{ lib, ... }:
{
  flake.modules.nixos.global =
    { ... }:
    {
      options = {
        modules.gateway = {
          tld = lib.mkOption {
            type = lib.types.str;
            default = "7sref";
            description = "Top-level domain for services";
          };
        };

        modules.ssh.enable = lib.mkEnableOption "OpenSSH";
        modules.tailscale.enable = lib.mkEnableOption "Tailscale";
        modules.samba.enable = lib.mkEnableOption "Samba";

        modules.users = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options.enable = lib.mkEnableOption "user account";
            }
          );
          default = { };
        };

        modules.containers = {
          media-sonarr = lib.mkEnableOption "Sonarr";
          media-radarr = lib.mkEnableOption "Radarr";
          media-prowlarr = lib.mkEnableOption "Prowlarr";
          media-flaresolverr = lib.mkEnableOption "FlareSolverr";
          media-qbittorrent = lib.mkEnableOption "qBittorrent";
          media-jellyfin = lib.mkEnableOption "Jellyfin";

          homeassistant = lib.mkEnableOption "Home Assistant";
          evcc = lib.mkEnableOption "evcc";
          mongo = lib.mkEnableOption "MongoDB";

          jenkins = lib.mkEnableOption "Jenkins";
          forgejo = lib.mkEnableOption "Forgejo";

          ai-searxng = lib.mkEnableOption "SearXNG";
          ai-openwebui = lib.mkEnableOption "Open WebUI";
          ai-copilot-api = lib.mkEnableOption "Copilot API";
          ai-langflow = lib.mkEnableOption "Langflow";
          silverbullet = lib.mkEnableOption "SilverBullet";

          minecraft-server = lib.mkEnableOption "Minecraft Server";

          gallery = lib.mkEnableOption "Gallery";

          immich = lib.mkEnableOption "Immich";
        };
      };
    };
}
