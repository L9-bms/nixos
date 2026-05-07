{ config, inputs, ... }:
{
  flake.hostNixpkgs.wky = inputs.nixpkgs-unstable;

  flake.modules.nixos."hosts/nixos/wky" = {
    imports = [
      ./_hardware.nix
      ./_configuration.nix

      inputs.home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [ inputs.yazi.overlays.default ];

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.backupFileExtension = "backup";
        home-manager.users.callum = import ./_home.nix;
      }
    ]
    ++ (with config.flake.modules.nixos; [
      zram

      callum

      tailscale

      desktop-niri
      desktop-audio
      desktop-bluetooth
      desktop-fonts
      desktop-printing
      desktop-noctalia

      syncthing-user
    ]);
  };
}
