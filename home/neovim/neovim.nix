{ config, nvf, ... }:

{
  programs.nvf = {
    enable = true;
    defaultEditor = true;

    settings = {
      vim = {
        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamed,unnamedplus";
        };

        keymaps = import ./keymap.nix { inherit nvf; };

        filetree.neo-tree = {
          enable = true;
        };

        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
        };

        viAlias = true;
        vimAlias = true;

        lsp = {
          enable = true;
          formatOnSave = true;
        };

        languages = {
          enableTreesitter = true;
          enableFormat = true;

          nix = {
            enable = true;
            format.type = "nixfmt";
          };
        };

        lineNumberMode = "relNumber";

        options = {
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;
          softtabstop = 2;
        };

      };
    };
  };
}
