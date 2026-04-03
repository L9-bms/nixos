{ config, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  flake.deploy.nodes.salt = {
    hostname = "salt";
    profiles.system = {
      user = "root";
      sshUser = "callum";
      interactiveSudo = true;
      path = inputs.deploy-rs.lib.${system}.activate.nixos config.flake.nixosConfigurations.salt;
    };
  };

  flake.nixosConfigurations.salt = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      config.flake.modules.nixos.salt
      inputs.disko.nixosModules.default
    ];
  };

  flake.modules.nixos.salt = {
    imports = [
      config.flake.nixosModules.salt-disko
      config.flake.nixosModules.salt-configuration

      config.flake.modules.nixos.callum

      config.flake.modules.nixos.ssh
      config.flake.modules.nixos.tailscale
    ];
  };
}
