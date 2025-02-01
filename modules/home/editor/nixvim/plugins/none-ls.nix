{
  programs.nixvim.plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
    sources.formatting = {
      buf.enable = true;
      nixfmt.enable = true;
    };
  };
}
