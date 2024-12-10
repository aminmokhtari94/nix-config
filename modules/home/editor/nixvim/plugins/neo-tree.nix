{
  programs.nixvim = {
  keymaps = [
      {
        mode = ["n"];
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options = {desc = "Open/Close Neotree";};
      }
  ];

    plugins.neo-tree = {
      enable = true;

      closeIfLastWindow = true;
      window = {
        width = 30;
        autoExpandWidth = true;
      };
    };
  };
}
