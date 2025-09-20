{ pkgs, ... }: {
  imports = [
    ./comment.nix
    ./conform.nix
    ./dadbod.nix
    ./dressing.nix
    ./dbtpal.nix
    ./floaterm.nix
    ./markdown-preview.nix
    ./neo-tree.nix
    ./neorg.nix
    ./startify.nix
    ./tagbar.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  programs.nixvim = {

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "sonokai";
        version = "v0.3.3";
        src = pkgs.fetchFromGitHub {
          owner = "sainnhe";
          repo = "sonokai";
          rev = "v0.3.3";
          sha256 = "sha256-QZQzflOC6cbFt7cwqnZ+y1kKWRWq05ty0x3aj6xuBTY=";
        };
      })
    ];

    extraConfigLua = ''
      vim.cmd("colorscheme sonokai")
    '';

    plugins = {
      web-devicons.enable = true;
      lz-n.enable = true;

      colorful-menu.enable = true;

      noice = { enable = true; };

      which-key.enable = true;

      nvim-autopairs.enable = true;

      wakatime.enable = true;

      nix.enable = true;

      colorizer = {
        enable = true;
        settings.user_default_options.names = false;
      };

      oil.enable = true;

      trim = {
        enable = true;
        settings = {
          highlight = true;
          ft_blocklist =
            [ "checkhealth" "floaterm" "lspinfo" "neo-tree" "TelescopePrompt" ];
        };
      };
    };
  };
}
