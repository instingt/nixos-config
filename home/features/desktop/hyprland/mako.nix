_: {
  services.mako = {
    enable = true;
    settings = {
      font = "Fira Sans 11";
      "background-color" = "#11111be6";
      "text-color" = "#cdd6f4";
      "border-color" = "#585b70";
      "border-radius" = 10;
      "border-size" = 2;
      padding = "10";
      "default-timeout" = 5000;
    };

    extraConfig = ''
      [urgency=high]
      default-timeout=0
      border-color=#f38ba8
    '';
  };
}
