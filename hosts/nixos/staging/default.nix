{ config, inputs, ... }:
{
  flake.modules.nixos."hosts/nixos/staging" = {
    imports = [
      inputs.disko.nixosModules.default
      ./_disko.nix
    ]
    ++ (with config.flake.nixosModules; [
      staging-configuration
    ])
    ++ (with config.flake.modules.nixos; [
      uefi
      impermanence-zfs
      persistence
      sops

      callum

      ssh
      tailscale

      gateway

    ]);
  };
}
