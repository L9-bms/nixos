{
  config,
  inputs,
  lib,
  ...
}:
let
  mkHosts =
    prefix: modules: builder:
    lib.mapAttrs' (
      name: module:
      let
        hostname = lib.removePrefix prefix name;
      in
      {
        name = hostname;
        value = builder hostname module;
      }
    ) (lib.filterAttrs (name: _: lib.hasPrefix prefix name) modules);
in
{
  flake.nixosConfigurations = lib.mkMerge [
    (mkHosts "hosts/nixos/" config.flake.modules.nixos (
      hostname: module:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { networking.hostName = hostname; }
          config.flake.modules.nixos.base
          config.flake.modules.nixos.global
          module
        ];
      }
    ))

    (config.flake.modules.iso or { })
  ];

  flake.deploy.nodes = lib.mapAttrs (hostname: hostConfiguration: {
    inherit hostname;
    profiles.system = {
      user = "root";
      sshUser = "callum";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos hostConfiguration;
    };
  }) config.flake.nixosConfigurations;
}
