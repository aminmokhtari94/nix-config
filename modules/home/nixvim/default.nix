{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./autocommands.nix
    ./buffer.nix
    ./completion.nix
    ./git.nix
    ./keymappings.nix
    ./lsp.nix
    ./options.nix
    ./statusline.nix
    ./todo.nix
  ];

  home.shellAliases.v = "nvim";

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.pkgs = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    version.enableNixpkgsReleaseCheck = false;

    #  performance = {
    #    combinePlugins = {
    #      enable = true;
    #      standalonePlugins = [
    #        "hmts.nvim"
    #        "neorg"
    #        "nvim-treesitter"
    #      ];
    #    };
    #    byteCompileLua.enable = true;
    #  };

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;
  };
}
