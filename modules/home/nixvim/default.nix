{ inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./autocommands.nix
    ./buffer.nix
    ./completion.nix
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
