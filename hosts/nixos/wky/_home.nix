{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "callum";
  home.homeDirectory = "/home/callum";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  fonts.fontconfig.enable = true;

  programs.noctalia-shell = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = config.home.username;
      user.email = "mail@callumwong.com";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    # disable nerd fonts
    theme = {
      status = {
        sep_left = {
          open = "";
          close = "";
        };
        sep_right = {
          open = "";
          close = "";
        };
      };

      icon = {
        globs = [ ];
        dirs = [ ];
        files = [ ];
        exts = [ ];
        conds = [ ];
      };

      indicator.padding = {
        open = "";
        close = "";
      };
    };
  };

  programs.foot =
    let
      foot-theme = pkgs.fetchurl {
        url = "https://codeberg.org/dnkl/foot/raw/branch/master/themes/moonfly";
        hash = "sha256-u5mARIGsE1CGnlskbfaUcnaSVdxGAQ6Wdn8qyPrC7ew=";
      };
    in
    {
      enable = true;
      server.enable = true;

      settings = {
        main = {
          include = "${foot-theme}";
          term = "xterm-256color";
          font = "BmPlus AST PremiumExec:size=16";
          pad = "4x4";
        };

        scrollback.lines = "16384";
        csd.preferred = "none";
      };
    };

  programs.vscode.enable = true;
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    mise.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting "We thirst for the seven wailings. We bear the koan of Jericho."
    '';
    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
  };

  programs.mise = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  home.file.".config/nvim" = {
    source = ./configs/nvim;
  };

  home.file.".config/niri" = {
    source = ./configs/niri;
  };

  home.packages = with pkgs; [
    ripgrep
  ];
}
