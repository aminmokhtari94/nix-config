{
  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
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
            gr = "rename";
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
            vuels.enable = false; # Vue
            pyright.enable = true; # Python
            marksman.enable = true; # Markdown
            nil_ls.enable = true; # Nix
            dockerls.enable = true; # Docker
            bashls.enable = true; # Bash
            clangd.enable = true; # C/C++
            # csharp_ls.enable = true; # C#
            yamlls.enable = true; # YAML
            ltex = {
              enable = true;
              settings = {
                enabled = [ "astro" "html" "latex" "markdown" "text" "tex" "gitcommit" ];
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
            gopls = { # Golang
              enable = true;
              autostart = true;
            };

            lua_ls = { # Lua
              enable = true;
              settings.telemetry.enable = false;
            };

            # Rust
            rust_analyzer = {
              enable = true;
              installRustc = true;
              installCargo = true;
            };
        };
      };
    };
  };
}
