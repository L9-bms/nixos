{ lib, ... }:
{
  flake.modules.nixos.global =
    { ... }:
    {
      options.modules.containers = {
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
        silverbullet = lib.mkEnableOption "SilverBullet";

        minecraft-server = lib.mkEnableOption "Minecraft Server";
      };
    };
}
