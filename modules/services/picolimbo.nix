{ inputs, ... }:
{
  flake.modules.nixos.picolimbo =
    { config, lib, ... }:
    {
      imports = [ inputs.picolimbo.nixosModules.default ];

      options.modules.picolimbo = {
        enable = lib.mkEnableOption "PicoLimbo limbo server";
      };

      config = lib.mkMerge [
        {
          modules.picolimbo.enable = lib.mkDefault true;
        }
        (lib.mkIf config.modules.picolimbo.enable {
          services.picolimbo = {
            enable = true;
            openFirewall = true;

            settings = {
              forwarding = {
                method = "MODERN";
                secret = "\${VELOCITY_SECRET}";
              };
            };
          };

          systemd.services.picolimbo = {
            serviceConfig.LoadCredential = "velocity-secret:/home/callum/velocity-secret";
            environment.VELOCITY_SECRET = "%d/velocity-secret";
          };
        })
      ];
    };
}
