{ pkgs, ... }:

{
  home.packages = [
    # pkgs.default.git-get
  ];

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
    extensions = with pkgs; [ gh-dash ];
  };

  programs.lazygit = {
    enable = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Amin Mokhtart";
        email = "amin.mokhtari94@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "nvim";
      };
      diff = {
        algorithm = "histogram";
      };
      status = {
        showUntrackedFiles = "all";
      };
      blame = {
        date = "relative";
      };
      rebase = {
        autosquash = true;
      };
      merge = {
        conflictStyle = "diff3";
      };
      pull = {
        ff = "only";
      };
      commit = {
        verbose = true;
      };
      url."git@github.com:".insteadOf = "https://github.com/";
      url."git@git.kiz.ir:".insteadOf = "https://git.kiz.ir/";
      credential.helper = "store";
    };

    signing = {
      key = "EC93568F7E2AB312";
      signByDefault = false;
    };

    ignores = [
      ".direnv"
      ".vim"
    ];

  };

}
