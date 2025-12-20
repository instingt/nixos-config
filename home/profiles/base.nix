# Base profile - applied to all users
{
  outputs,
  ...
}:
{
  imports = [
    ../features/neovim
  ]
  ++ (builtins.attrValues outputs.homeManagerModules);

  programs = {
    home-manager.enable = true;
  };
}
