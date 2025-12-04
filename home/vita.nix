{ config, pkgs, nvf, ... }:

{
  home.username = "vita";
  home.homeDirectory = "/home/vita";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fd
    ripgrep
    tmux
  ];

  programs.git = {
    enable = true;
    userName = "Vitalii Kataev";
    userEmail = "vita@kataev.pro";
  };

  imports = [
    nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    defaultEditor = true;

    settings = {
      vim = {
        viAlias = true;
	vimAlias = true;

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
