{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [ shfmt ];
    plugins.conform-nvim = {
      enable = true;

      lazyLoad.settings = {
        cmd = [ "ConformInfo" ];
        event = [ "BufWrite" ];
      };

      settings = {
        format_on_save = {
          lspFallback = true;
          # timeoutMs = 500;
        };
        notify_on_error = true;

        formatters_by_ft = {
          html = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          css = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          javascript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          javascriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          typescript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          typescriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          markdown = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          # java = [ "google-java-format" ];
          python = [ "black" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          go = [
            "gofmt"
            "goimports"
          ];
          # rust = [ "rustfmt" ];
          # liquidsoap = [ "liquidsoap-prettier" ];
          yaml = [
            "yamllint"
            "yamlfmt"
          ];
          # terragrunt = [ "hcl" ];
          bash = [ "shfmt" ];
          sh = [ "shfmt" ];
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>uf";
        action = ":FormatToggle<CR>";
        options = {
          desc = "Toggle Format Globally";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>uF";
        action = ":FormatToggle!<CR>";
        options = {
          desc = "Toggle Format Locally";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format Buffer";
        };
      }

      {
        mode = "v";
        key = "<leader>cF";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format Lines";
        };
      }
    ];
  };
}
