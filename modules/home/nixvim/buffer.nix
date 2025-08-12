{ pkgs, ... }: {
  programs.nixvim = {

    plugins.barbar = {
      enable = true;
      keymaps = {
        next.key = "<TAB>";
        previous.key = "<S-TAB>";
        close.key = "<C-w>";
      };
    };

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "hbac";
        version = "v3.0.0";
        src = pkgs.fetchFromGitHub {
          owner = "axkirillov";
          repo = "hbac.nvim";
          rev = "cf16fc15ede8411dd2f5b7f909f3027ea54a10b9";
          hash = "sha256-kIStYRQyoxe2e9pGE0Ie4xV04sGKEBbaZXvS7CT5DQ0=";
        };
        doCheck = false;
      })
    ];

    extraConfigLua = ''
      require("hbac").setup({
        autoclose     = true, -- set autoclose to false if you want to close manually
        threshold     = 10, -- hbac will start closing unedited buffers once that number is reached
        close_command = function(bufnr)
          vim.api.nvim_buf_delete(bufnr, {})
        end,
        close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
      })
    '';
  };
}
