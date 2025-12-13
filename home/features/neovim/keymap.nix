{ nvf, ... }:

let
  inherit (nvf.lib.nvim.binds) mkKeymap;
in
[
  (mkKeymap "n" "<leader>e" "<CMD>Neotree toggle<CR>" {
    desc = "Toggle Neo-tree";
  })
  (mkKeymap "n" "<C-h>" "<C-w>h" {
    desc = "Focus window left";
  })
  (mkKeymap "n" "<C-l>" "<C-w>l" {
    desc = "Focus window right";
  })
]
