{ lib, ... }:
{
  options.flake.hostNixpkgs = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Per-host nixpkgs override; hosts not listed here use inputs.nixpkgs.";
  };
}
