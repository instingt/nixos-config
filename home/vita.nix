{
  config,
  pkgs,
  nvf,
  ...
}:
{
  home.username = "vita";
  home.homeDirectory = "/home/vita";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fd
    ripgrep
    tmux
  ];

  imports = [
    nvf.homeManagerModules.default
    ./neovim/neovim.nix
    ./hyprland.nix
    ./git.nix
  ];

}
