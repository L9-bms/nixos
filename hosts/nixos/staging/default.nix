{
  config,
  inputs,
  microvmLib,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/staging" = {
    imports = [
      ./_disko.nix
      ./_configuration.nix

      inputs.disko.nixosModules.default
      inputs.microvm.nixosModules.host
      (microvmLib.mkHostNetworking {
        n = 1;
        hostname = "gallery";
      })
    ]
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

    microvm.vms.gallery = {
      flake = inputs.self;
      restartIfChanged = true;
    };
  };
}
