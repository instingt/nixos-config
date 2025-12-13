{
  stdenvNoCC,
  writeShellScriptBin,
  hyprland,
}:

let
  wrapper = writeShellScriptBin "hyprland-session-quiet" ''
    mkdir -p "$HOME/.local/state"
    exec ${hyprland}/bin/Hyprland >"$HOME/.local/state/hyprland.log" 2>&1
  '';
in
stdenvNoCC.mkDerivation {
  pname = "hyprland-session-quiet";
  version = "1.0.0";

  buildCommand = ''
        mkdir -p $out/share/wayland-sessions

        cat > $out/share/wayland-sessions/hyprland-quiet.desktop <<EOF
    [Desktop Entry]
    Name=Hyprland (quiet)
    Comment=Hyprland with logs redirected to ~/.local/state/hyprland.log
    Exec=${wrapper}/bin/hyprland-session-quiet
    Type=Application
    DesktopNames=Hyprland
    EOF
  '';
  passthru.providedSessions = [ "hyprland-quiet" ];
}
