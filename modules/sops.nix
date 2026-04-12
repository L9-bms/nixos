{ inputs, ... }:
{
  flake.modules.nixos.sops =
    {
      config,
      lib,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../secrets/secrets.yaml;
        age.sshKeyPaths = [
          "${lib.attrByPath [ "persistence" "persistDir" ] "" config}/etc/ssh/ssh_host_ed25519_key"
        ];
      };
    };
}
