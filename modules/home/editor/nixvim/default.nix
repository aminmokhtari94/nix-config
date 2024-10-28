{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home.packages = with pkgs; [
    
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    #colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      nvim-autopairs.enable = false;
    };
    
    extraPlugins = [ pkgs.vimPlugins.gruvbox ];

#    performance = {
#      combinePlugins = {
#        enable = true;
#        standalonePlugins = [
#          "hmts.nvim"
#          "neorg"
#          "nvim-treesitter"
#        ];
#      };
#      byteCompileLua.enable = true;
#    };

    colorscheme = "gruvbox";
       # Use <Space> as leader key
    globals.mapleader = " ";

    # Set 'vi' and 'vim' aliases to nixvim
    viAlias = true;
    vimAlias = true;
    
    luaLoader.enable = true;

    # Setup clipboard support
    clipboard = {
      # Use xsel as clipboard provider
      providers.xsel.enable = true;

      # Sync system clipboard
      register = "unnamedplus";
    };

  };
}
