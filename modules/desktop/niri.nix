{
  flake.modules.nixos.desktop-niri = {
    programs.niri.enable = true;
    xdg.portal.enable = true;
  };
}
