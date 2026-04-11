{ config, ... }:
{
  flake.modules.nixos."hosts/nixos/salt" = {
    imports =
      (with config.flake.nixosModules; [
        salt-disko
        salt-configuration
      ])
      ++ (with config.flake.modules.nixos; [
        base
        uefi
        zram

        callum

        ssh
        tailscale
        mc-server
      ]);
  };
}
