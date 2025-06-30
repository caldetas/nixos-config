{ config, lib, ... }:

{
  time.timeZone = "Europe/Zurich";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_CH.UTF-8/UTF-8"
      "es_MX.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "de_CH.UTF-8";
      LC_MONETARY = "de_CH.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "sg";
  };
}
