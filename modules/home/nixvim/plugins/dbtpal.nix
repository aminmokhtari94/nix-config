{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "dbtpal";
        version = "v0.0.6";
        src = pkgs.fetchFromGitHub {
          owner = "PedramNavid";
          repo = "dbtpal";
          rev = "v0.0.6";
          sha256 = "sha256-AvjA8YSnD7gS9K07uYaVIcTA+6YmG44uyWzNkVyeSeQ=";
        };
        doCheck = false;
      })
    ];

    extraConfigLua = ''
      require("dbtpal").setup({
          path_to_dbt = "dbt",
          path_to_dbt_project = "",
          path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
          include_profiles_dir = true,
          include_project_dir = true,
          include_log_level = true,
          extended_path_search = true,
          protect_compiled_files = true,
          pre_cmd_args = {},
          post_cmd_args = {},
      })
      require("telescope").load_extension("dbtpal")
    '';
    # { "<leader>dtf", "<cmd>DbtTest<cr>" },
    # { "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
    keymaps = [
      {
        mode = "n";
        key = "<leader>brf";
        action = "<cmd>DbtRun<cr>";
        options = {
          silent = false;
          desc = "DBT Run File";
        };
      }
      {
        mode = "n";
        key = "<leader>brp";
        action = "<cmd>DbtRunAll<cr>";
        options = {
          silent = false;
          desc = "DBT Run Project";
        };
      }
    ];

  };
}
