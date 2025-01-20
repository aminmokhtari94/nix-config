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

  programs.git = {
    enable = true;
    userName = "Amin Mokhtart";
    userEmail = "amin.mokhtari94@gmail.com";

    signing = {
      key = "EC93568F7E2AB312";
      signByDefault = true;
    };

    ignores = [ ".direnv" ".vim" ];

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    extraConfig = {
      init = { defaultBranch = "main"; };
      core = { editor = "nvim"; };
      diff = { algorithm = "histogram"; };
      status = { showUntrackedFiles = "all"; };
      blame = { date = "relative"; };
      rebase = { autosquash = true; };
      merge = { conflictStyle = "diff3"; };
      pull = { ff = "only"; };
      commit = { verbose = true; };
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

}
