{ lib, ... }:
{
  config.flake.factory.user = username: isAdmin: hasSopsPassword: {
    nixos."${username}" = {
      users.users."${username}" = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [ "wheel" ];
      };

      nix.settings.trusted-users = lib.optionals isAdmin [ username ];
    };

    nixos.sops =
      { config, ... }:
      lib.mkIf hasSopsPassword {
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
  };
}
