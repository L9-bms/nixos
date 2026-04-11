{ config, ... }:
{
  flake.modules.nixos."hosts/nixos/liz" = {
    imports =
      (with config.flake.nixosModules; [
        liz-disko
        liz-configuration
        liz-networking
      ])
      ++ (with config.flake.modules.nixos; [
        base
        uefi
        zram

        impermanence-zfs
        persistence

        callum
        colin

        ssh
        tailscale
      ]);
  };
}
