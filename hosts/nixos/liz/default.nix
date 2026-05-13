{
  config,
  inputs,
  microvmLib,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/liz" = {
    imports = [
      # convention: write all host-specific configuration as regular
      # nixos modules instead of flake-parts modules.
      ./_disko.nix
      ./_configuration.nix
      ./_networking.nix

      inputs.disko.nixosModules.default
      inputs.microvm.nixosModules.host
      (microvmLib.mkHostNetworking {
        n = 1;
        hostname = "vm-gallery";
      })
    ]
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
      quadlet-immich
    ]);

    microvm.vms.vm-gallery = {
      flake = inputs.self;
      restartIfChanged = true;
    };
  };
}
