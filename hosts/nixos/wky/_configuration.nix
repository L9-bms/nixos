{
  config,
  pkgs,
  lib,
  ...
}:
{
  system.stateVersion = "25.11";

  boot.loader.limine.enable = true;

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernel.sysctl."ibt" = "off";

  hardware.facetimehd.enable = true;
  hardware.enableAllFirmware = true;

  i18n.defaultLocale = lib.mkForce "en_AU.UTF-8";
  documentation.man.cache.enable = false;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  zramSwap.algorithm = lib.mkForce "lzo";
  zramSwap.priority = 100;

  powerManagement.enable = true;
  services.tuned.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  programs.nix-ld.enable = true;
  programs.kdeconnect.enable = true;

  users.users.callum.extraGroups = [
    "networkmanager"
    "adbusers"
  ];

  programs.firefox = {
    enable = true;
    autoConfig = ''
      // Any comment. You must start the file with a single-line comment!
      var { classes: Cc, interfaces: Ci, utils: Cu } = Components;

      // Set new tab page
      try {
        ChromeUtils.importESModule(
          "resource:///modules/AboutNewTab.sys.mjs",
        ).AboutNewTab.newTabURL = "https://prism.tower.7sref";
      } catch (e) {
        Cu.reportError(e);
      } // report errors in the Browser Console

      // Auto focus new tab content
      try {
        const { BrowserWindowTracker } = ChromeUtils.importESModule(
          "resource:///modules/BrowserWindowTracker.sys.mjs",
        );
        const Services = globalThis.Services;
        Services.obs.addObserver((event) => {
          window = BrowserWindowTracker.getTopWindow();
          window.gBrowser.selectedBrowser.focus();
        }, "browser-open-newtab-start");
      } catch (e) {
        Cu.reportError(e);
      }
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowInsecurePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "broadcom-sta" ];
  };

  nix.settings = {
    trusted-users = [ "callum" ];
    extra-substituters = [ "https://yazi.cachix.org" ];
    extra-trusted-public-keys = [ "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" ];
  };

  nix.buildMachines = [
    {
      hostName = "acid";
      sshUser = "callum";
      system = "x86_64-linux";
      maxJobs = 6;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.qttools
    kdePackages.okular
    vim
    wget
    git
    foot
    adwaita-icon-theme
    nmap
    qalculate-gtk
    vesktop
    obsidian
    nautilus
    scrcpy
    android-tools
    blueman
    pavucontrol
    libreoffice-fresh
    xournalpp
    btop
    nixd
    nixfmt
    unzip
    (texliveBasic.withPackages (
      ps: with ps; [
        collection-xetex
        collection-latex
        collection-basic
        collection-luatex
        collection-binextra
        collection-fontutils
        collection-latexextra
        collection-bibtexextra
        collection-mathscience
        collection-plaingeneric
        collection-formatsextra
        collection-latexrecommended
        collection-fontsrecommended
      ]
    ))
    zellij
    wl-clipboard
    lua-language-server
    ncdu
    foliate
    markdown-oxide
    zathura
    tinymist
    websocat
  ];
}
