{ pkgs, ... }:
{
  home.sessionVariables.NIXOS_CONFIG = "/home/vita/nixos-config";

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];

    interactiveShellInit = ''
      function __nixos_config_path
        if set -q NIXOS_CONFIG
          echo $NIXOS_CONFIG
        else
          echo /home/vita/nixos-config
        end
      end

      function __nixos_rebuild --description "nixos-rebuild <action> --flake $NIXOS_CONFIG#<host> (host defaults to hostname; override: nrs thinkpad)" --argument-names action
        set -l flakePath (__nixos_config_path)
        set -l host (hostname)
        set -l args $argv[2..-1]

        if test (count $argv) -ge 2; and not string match -qr '^-{1,2}' -- $argv[2]
          set host $argv[2]
          set args $argv[3..-1]
        end

        if test (id -u) -eq 0
          command nixos-rebuild $action --flake "$flakePath#$host" $args
        else
          command sudo nixos-rebuild $action --flake "$flakePath#$host" $args
        end
      end

      function nrs --description "sudo nixos-rebuild switch --flake $NIXOS_CONFIG#<host> (host defaults to hostname; override: nrs thinkpad)"
        __nixos_rebuild switch $argv
      end

      function nrt --description "sudo nixos-rebuild test --flake $NIXOS_CONFIG#<host> (host defaults to hostname; override: nrt thinkpad)"
        __nixos_rebuild test $argv
      end
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;

      format = "$directory$git_branch$git_status$nix_shell$cmd_duration$status$character";

      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "blue";
      };

      git_branch = {
        format = " [$symbol$branch]($style)";
        symbol = " ";
        style = "purple";
      };

      git_status = {
        format = " [$all_status$ahead_behind]($style)";
        style = "yellow";
      };

      nix_shell = {
        format = " [$symbol$state]($style)";
        symbol = " ";
        style = "cyan";
      };

      cmd_duration = {
        format = " [$duration]($style)";
        style = "bright-black";
        min_time = 500;
      };

      status = {
        disabled = false;
        format = " [$status]($style)";
        style = "red";
      };
    };
  };
}

