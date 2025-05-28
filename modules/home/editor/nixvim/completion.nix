{ pkgs, ... }: {
  programs.nixvim = {
    opts.completeopt = [ "menu" "menuone" "noselect" ];

    extraPlugins = with pkgs.vimPlugins;
      [
        # blink-cmp-copilot
        blink-ripgrep-nvim
      ];

    plugins = {
      luasnip.enable = true;
      friendly-snippets.enable = true;
      blink-cmp-copilot.enable = false;
      blink-cmp-dictionary.enable = true;
      blink-cmp-git.enable = true;
      blink-cmp-spell.enable = true;
      blink-copilot.enable = false;
      blink-emoji.enable = true;
      blink-ripgrep.enable = true;
      vim-dadbod-completion.enable = true;
      blink-cmp = {
        enable = true;
        setupLspCapabilities = true;

        settings = {
          keymap = { preset = "super-tab"; };
          signature = { enabled = true; };

          snippets = { preset = "luasnip"; };

          sources = {
            default = [
              "buffer"
              "lsp"
              "path"
              "snippets"
              # Community
              # "copilot"
              "dictionary"
              "emoji"
              # "git"
              "spell"
              "ripgrep"
            ];
            per_filetype = { sql = [ "snippets" "dadbod" "buffer" ]; };
            providers = {
              ripgrep = {
                name = "Ripgrep";
                module = "blink-ripgrep";
                score_offset = 1;
              };
              spell = {
                name = "Spell";
                module = "blink-cmp-spell";
                score_offset = 1;
              };
              dictionary = {
                name = "Dict";
                module = "blink-cmp-dictionary";
                min_keyword_length = 3;
              };
              emoji = {
                name = "Emoji";
                module = "blink-emoji";
                score_offset = 1;
              };
              lsp.score_offset = 4;
              dadbod = {
                name = "Dadbod";
                module = "vim_dadbod_completion.blink";
                score_offset = 2;
              };
              copilot = {
                name = "copilot";
                module = "blink-copilot";
                async = false;
                score_offset = 100;
              };
              git = {
                name = "Git";
                module = "blink-cmp-git";
                enabled = false;
                score_offset = 100;
                should_show_items.__raw = ''
                  function()
                    return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown'
                  end
                '';
                opts = {
                  git_centers = {
                    github = {
                      issue = {
                        on_error.__raw = "function(_,_) return true end";
                      };
                    };
                  };
                };
              };
            };
          };

          appearance = {
            nerd_font_variant = "mono";
            kind_icons = {
              Text = "󰉿";
              Method = "";
              Function = "󰊕";
              Constructor = "󰒓";

              Field = "󰜢";
              Variable = "󰆦";
              Property = "󰖷";

              Class = "󱡠";
              Interface = "󱡠";
              Struct = "󱡠";
              Module = "󰅩";

              Unit = "󰪚";
              Value = "󰦨";
              Enum = "󰦨";
              EnumMember = "󰦨";

              Keyword = "󰻾";
              Constant = "󰏿";

              Snippet = "󱄽";
              Color = "󰏘";
              File = "󰈔";
              Reference = "󰬲";
              Folder = "󰉋";
              Event = "󱐋";
              Operator = "󰪚";
              TypeParameter = "󰬛";
              Error = "󰏭";
              Warning = "󰏯";
              Information = "󰏮";
              Hint = "󰏭";

              Emoji = "🤶";
            };
          };
          completion = {
            menu = {
              border = "none";
              draw = {
                gap = 1;
                treesitter = [ "lsp" ];
                columns = [
                  { __unkeyed-1 = "label"; }
                  {
                    __unkeyed-1 = "kind_icon";
                    __unkeyed-2 = "kind";
                    gap = 1;
                  }
                  { __unkeyed-1 = "source_name"; }
                ];
              };
            };
            trigger = { show_in_snippet = false; };
            documentation = {
              auto_show = true;
              window = { border = "single"; };
            };
            accept = { auto_brackets = { enabled = false; }; };
          };
        };
      };
    };

    # ================ cmp plugin (disabled) ==============
    plugins = {

      cmp-spell = { enable = false; };

      lspkind = {
        enable = false;

        cmp = {
          enable = false;
          menu = {
            nvim_lsp = "[LSP]";
            nvim_lua = "[api]";
            path = "[path]";
            luasnip = "[snip]";
            buffer = "[buffer]";
            neorg = "[neorg]";
            nixpkgs_maintainers = "[nixpkgs]";
          };
        };
      };

      cmp = {
        enable = false;

        settings = {
          snippet.expand =
            "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" =
              "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };

          sources = [
            { name = "path"; }
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            {
              name = "buffer";
              # Words from other open buffers can also be suggested.
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            }
            { name = "neorg"; }
            { name = "nixpkgs_maintainers"; }
          ];
        };
      };
    };
  };
}
