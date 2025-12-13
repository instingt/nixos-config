{
  programs.git = {
    enable = true;

    settings = {
      user.name = "Vitaliy Kataev";
      user.email = "vita@kataev.pro";

      signing = {
        key = "6664158A96D5F5D9DB8CD5DDBB28505EC0F75404";
        signByDefault = true;
      };
    };
  };
}
