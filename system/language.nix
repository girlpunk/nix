{
  config,
  pkgs,
  lib,
  currentSystem,
  currentSystemName,
  ...
}: {
  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };

  console.keyMap = "uk";
}
