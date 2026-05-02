{ config, inputs, ... }:
{
  flake.modules.nixos."hosts/nixos/liz" = {
    imports = [
      inputs.disko.nixosModules.default
      ./_disko.nix

      inputs.quadlet-nix.nixosModules.quadlet
    ]
    ++ (with config.flake.nixosModules; [
      liz-configuration
      liz-networking
    ])
    ++ (with config.flake.modules.nixos; [
      uefi
      zram
      impermanence-zfs
      persistence
      sops

      callum
      colin

      ssh
      tailscale
      gateway
      monitoring
      samba
      syncthing
      qbittorrent

      quadlet-productivity
      quadlet-media
      quadlet-automation
      quadlet-development
    ]);
  };
}
