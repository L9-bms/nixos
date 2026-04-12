let
  username = "callum";
in
{
  flake.modules.nixos.${username} =
    { pkgs, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = [
          "wheel"
        ];
        shell = pkgs.fish;
        initialPassword = "changeme";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMP4bm4SjbUcveDfeNVU7QkWz/pFWuVrPsZIa5e6ZE64 callum@acid"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw8zK93i7WJYfbmpcXE5ZYTWRvkm3ohIdsvWmWOkCFQ callum@wky"
        ];
      };
      programs.fish.enable = true;
      nix.settings.trusted-users = [ username ];
    };

  flake.modules.nixos.sops =
    {
      config,
      lib,
      ...
    }:
    {
      sops.secrets."passwords/${username}" = {
        owner = "root";
        group = "root";
        mode = "0400";
        neededForUsers = true;
      };

      users.users.${username} = {
        initialPassword = lib.mkForce null;
        hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
      };
    };
}
