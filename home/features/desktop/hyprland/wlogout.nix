{ pkgs, ... }:
{
  home.packages = [ pkgs.wlogout ];

  xdg.configFile."wlogout/layout".text = ''
    {
      "label" : "lock",
      "action" : "hyprlock",
      "text" : "Lock",
      "keybind" : "l"
    }
    {
      "label" : "logout",
      "action" : "hyprctl dispatch exit",
      "text" : "Logout",
      "keybind" : "e"
    }
    {
      "label" : "suspend",
      "action" : "systemctl suspend",
      "text" : "Suspend",
      "keybind" : "s"
    }
    {
      "label" : "reboot",
      "action" : "systemctl reboot",
      "text" : "Reboot",
      "keybind" : "r"
    }
    {
      "label" : "shutdown",
      "action" : "systemctl poweroff",
      "text" : "Shutdown",
      "keybind" : "p"
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
      font-family: Fira Sans, FiraMono Nerd Font;
      font-size: 14pt;
    }

    window {
      background: rgba(17, 17, 27, 0.92);
    }

    button {
      padding: 12px;
      margin: 12px;
      border-radius: 14px;
      border: 2px solid rgba(88, 91, 112, 0.7);
      color: rgba(205, 214, 244, 1.0);
      background: rgba(30, 30, 46, 0.55);
    }

    button:focus,
    button:hover {
      border: 2px solid rgba(137, 180, 250, 0.9);
      background: rgba(49, 50, 68, 0.75);
    }
  '';
}
