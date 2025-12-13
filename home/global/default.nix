{
  config,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ../features/cli
    ../features/neovim
  ]
  ++ (builtins.attrValues outputs.homeManagerModules);

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = "vita";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "25.11";
  };
}
