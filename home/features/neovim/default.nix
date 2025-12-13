{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (inputs) lazyvim-config;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  home.activation.installNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu

    target="${config.xdg.configHome}/nvim"
    src="${lazyvim-config}"

    mkdir -p "${config.xdg.configHome}"
    rm -fr "$target"

    cp -aT "$src" "$target"
    chmod -R u+w "$target"
  '';

  xdg.configFile."nvim/lua/plugins/zz_nixos_no_mason.lua".text = ''
    return {
      -- Полностью вырубаем Mason
      { "mason-org/mason.nvim", enabled = false },
      { "mason-org/mason-lspconfig.nvim", enabled = false },

      -- И на всякий случай говорим: “ни один сервер не через mason”
      {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
          opts.servers = opts.servers or {}
          opts.servers["*"] = opts.servers["*"] or {}
          opts.servers["*"].mason = false
        end,
      },
    }
  '';

  home.packages = with pkgs; [
    # basic
    ripgrep
    fd
    tree-sitter
    lua5_1
    lua51Packages.luarocks
    lazygit
    fzf

    # plugin build envirement
    gcc
    gnumake
    cmake
    pkg-config

    # nix
    nil
    nixfmt-rfc-style
    statix # nix linter
    deadnix # dead code

    # Lua
    lua-language-server
    stylua
  ];
}
