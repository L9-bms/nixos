{ lib, ... }:
{
  flake.modules.nixos.samba =
    { pkgs, config, ... }:
    {
      options.modules.samba = {
        shares = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };
      };

      config = {
        modules.samba.enable = lib.mkDefault true;

        services = {
          samba = {
            package = pkgs.samba4Full;
            enable = true;
            openFirewall = true;

            # do not forget: # smbpasswd -a username

            settings =
              let
                shares = builtins.mapAttrs (_: path: {
                  inherit path;
                  browseable = true;
                  "read only" = false;
                  "guest ok" = false;
                  "follow symlinks" = true;
                  "wide links" = true;
                }) config.modules.samba.shares;
              in
              {
                global = {
                  "allow insecure wide links" = true;
                };
              }
              // shares;
          };

          avahi = {
            enable = true;
            publish.enable = true;
            publish.userServices = true;
            nssmdns4 = true;
            openFirewall = true;
          };

          samba-wsdd = {
            enable = true;
            openFirewall = true;
          };
        };
      };
    };

  flake.modules.nixos.persistence =
    { config, ... }:
    {
      environment.persistence.${config.modules.persistence.persistDir}.directories =
        lib.mkIf config.modules.samba.enable
          [ "/var/lib/samba" ];
    };
}
