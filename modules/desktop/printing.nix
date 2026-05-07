{
  flake.modules.nixos.desktop-printing = {
    services.printing.enable = true;
    services.udisks2.enable = true;
  };
}
