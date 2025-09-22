{
  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
        # autoLoad = true;
        lspServersToEnable = "all";
      };

      lsp = {
        enable = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
            "<F2>" = "rename";
          };
        };

        servers = {
          ts_ls.enable = true; # TS/JS
          cssls.enable = true; # CSS
          tailwindcss.enable = true; # TailwindCSS
          html.enable = true; # HTML
          # astro.enable = true; # AstroJS
          # phpactor.enable = true; # PHP
          # svelte.enable = false; # Svelte
          # Vue
          volar = {
            enable = true;
            filetypes = [
              "typescript"
              "javascript"
              "javascriptreact"
              "typescriptreact"
              "vue"
            ];
          };
          eslint.enable = true; # ESLint
          pyright.enable = true; # Python
          marksman.enable = true; # Markdown
          nil_ls.enable = true; # Nix
          dockerls.enable = true; # Docker
          bashls.enable = true; # Bash
          buf_ls.enable = true; # Protobuf
          # csharp_ls.enable = true; # C#
          yamlls.enable = true; # YAML
          clangd = {
            # C/C++
            enable = true;
            filetypes = [
              "c"
              "cpp"
              "cc"
              "mpp"
              "ixx"
            ];
          };
          ltex = {
            enable = false;
            settings = {
              enabled = [
                "astro"
                "html"
                "latex"
                "markdown"
                "text"
                "tex"
                "gitcommit"
              ];
              completionEnabled = true;
              language = "en-US de-DE nl";
              # dictionary = {
              #   "nl-NL" = [
              #     ":/home/liv/.local/share/nvim/ltex/nl-NL.txt"
              #   ];
              #   "en-US" = [
              #     ":/home/liv/.local/share/nvim/ltex/en-US.txt"
              #   ];
              #   "de-DE" = [
              #     ":/home/liv/.local/share/nvim/ltex/de-DE.txt"
              #   ];
              # };
            };
          };
          gopls = {
            # Golang
            enable = true;
            autostart = true;
          };

          lua_ls = {
            # Lua
            enable = true;
            settings.telemetry.enable = false;
          };

          # Rust
          rust_analyzer = {
            enable = true;
            installRustc = false;
            installCargo = false;
          };
        };
      };

      trouble = {
        enable = true;
        settings = {
          auto_close = true;
        };
      };

      lspsaga = {
        enable = true;
        settings = {
          beacon = {
            enable = true;
          };
          ui = {
            border = "rounded"; # One of none, single, double, rounded, solid, shadow
            codeAction = "💡"; # Can be any symbol you want 💡
          };
          hover = {
            openCmd = "!floorp"; # Choose your browser
            openLink = "gx";
          };
          diagnostic = {
            borderFollow = true;
            diagnosticOnlyCurrent = false;
            showCodeAction = true;
          };
          symbolInWinbar = {
            enable = true; # Breadcrumbs
          };
          codeAction = {
            extendGitSigns = false;
            showServerName = true;
            onlyInCursor = true;
            numShortcut = true;
            keys = {
              exec = "<CR>";
              quit = [
                "<Esc>"
                "q"
              ];
            };
          };
          lightbulb = {
            enable = false;
            sign = false;
            virtualText = true;
          };
          implement = {
            enable = false;
          };
          rename = {
            autoSave = false;
            keys = {
              exec = "<CR>";
              quit = [
                "<C-k>"
                "<Esc>"
              ];
              select = "x";
            };
          };
          outline = {
            autoClose = true;
            autoPreview = true;
            closeAfterJump = true;
            layout = "normal"; # normal or float
            winPosition = "right"; # left or right
            keys = {
              jump = "e";
              quit = "q";
              toggleOrJump = "o";
            };
          };
          scrollPreview = {
            scrollDown = "<C-f>";
            scrollUp = "<C-b>";
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>x";
        action = "+diagnostics/quickfix";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options = {
          silent = true;
          desc = "Diagnostics (Trouble)";
        };
      }
      {
        mode = "n";
        key = "<leader>xX";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options = {
          silent = true;
          desc = "Buffer Diagnostics (Trouble)";
        };
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = "<cmd>Trouble todo<cr>";
        options = {
          silent = true;
          desc = "Todo (Trouble)";
        };
      }
      {
        mode = "n";
        key = "<leader>xQ";
        action = "<cmd>Trouble qflist toggle<cr>";
        options = {
          silent = true;
          desc = "Quickfix List (Trouble)";
        };
      }
    ];
  };
}
