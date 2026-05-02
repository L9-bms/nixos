{ config, inputs, ... }:
{
  flake.modules.nixos."hosts/nixos/salt" = {
    imports = [
      inputs.disko.nixosModules.default
      ./_disko.nix

      inputs.quadlet-nix.nixosModules.quadlet
    ]
    ++ (with config.flake.nixosModules; [
      salt-configuration
    ])
    ++ (with config.flake.modules.nixos; [
      uefi
      zram

      callum

      ssh
      tailscale
    ]);
  };
}
