{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    plugins = {
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };
      fugitive.enable = true;
      diffview.enable = true;
      lazygit.enable = true;
    };

    keymaps = [
      # =======================
      # Gitsigns
      # =======================
      {
        mode = "n";
        key = "]c";
        action = "<cmd>Gitsigns next_hunk<CR>";
        options.desc = "Next hunk";
      }
      {
        mode = "n";
        key = "[c";
        action = "<cmd>Gitsigns prev_hunk<CR>";
        options.desc = "Previous hunk";
      }

      # Hunk actions
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>Gitsigns stage_hunk<CR>";
        options.desc = "Stage hunk";
      }
      {
        mode = "v";
        key = "<leader>gs";
        action = ":Gitsigns stage_hunk<CR>";
        options.desc = "Stage selection";
      }
      {
        mode = "n";
        key = "<leader>gr";
        action = "<cmd>Gitsigns reset_hunk<CR>";
        options.desc = "Reset hunk";
      }
      {
        mode = "v";
        key = "<leader>gr";
        action = ":Gitsigns reset_hunk<CR>";
        options.desc = "Reset selection";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<CR>";
        options.desc = "Preview hunk";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns blame_line<CR>";
        options.desc = "Blame current line";
      }
      {
        mode = "n";
        key = "<leader>gB";
        action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
        options.desc = "Toggle line blame";
      }
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>Gitsigns diffthis<CR>";
        options.desc = "Diff against index";
      }
      {
        mode = "n";
        key = "<leader>gD";
        action = "<cmd>Gitsigns diffthis ~<CR>";
        options.desc = "Diff against last commit";
      }

      # =======================
      # Fugitive
      # =======================
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Git<CR>";
        options.desc = "Git status (fugitive)";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Git commit<CR>";
        options.desc = "Git commit";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Git push<CR>";
        options.desc = "Git push";
      }
      {
        mode = "n";
        key = "<leader>gP";
        action = "<cmd>Git pull<CR>";
        options.desc = "Git pull";
      }

      # =======================
      # Diffview
      # =======================
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<CR>";
        options.desc = "Open Diffview";
      }
      {
        mode = "n";
        key = "<leader>gq";
        action = "<cmd>DiffviewClose<CR>";
        options.desc = "Close Diffview";
      }
      {
        mode = "n";
        key = "<leader>gh";
        action = "<cmd>DiffviewFileHistory<CR>";
        options.desc = "Git file history";
      }

      # =======================
      # LazyGit
      # =======================
      {
        mode = "n";
        key = "<leader>gl";
        action = "<cmd>LazyGit<CR>";
        options.desc = "Open LazyGit";
      }
    ];
  };
}
