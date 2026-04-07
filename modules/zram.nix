{
  flake.modules.nixos.zram = {
    zramSwap.enable = true;

    # kernel's native OOM killer can sometimes fail to trigger
    systemd.oomd.enable = true;
  };
}
