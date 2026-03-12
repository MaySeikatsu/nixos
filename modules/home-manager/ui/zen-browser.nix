{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    # inputs.zen-browser.packages."${system}".specific
    # Docu: https://github.com/0xc000022070/zen-browser-flake
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];
  # programs.zen-browser.policies = {
  #   AutofillAddressEnabled = true;
  #   AutofillCreditCardEnabled = false;
  #   DisableAppUpdate = true;
  #   DisableFeedbackCommands = true;
  #   DisableFirefoxStudies = true;
  #   DisablePocket = true;
  #   DisableTelemetry = true;
  #   DontCheckDefaultBrowser = true;
  #   NoDefaultBookmarks = true;
  #   OfferToSaveLogins = false;
  #   EnableTrackingProtection = {
  #     Value = true;
  #     Locked = true;
  #     Cryptomining = true;
  #     Fingerprinting = true;
  #   };
  # };
  # programs.zen-browser.profiles.*.settings = {
  #   "browser.tabs.warnOnClose" = false;
  #   "browser.download.panel.shown" = false;
  #   # Since this is a json value, it can be nixified and translated by home-manager;
  #   browser = {
  #     tabs.warnOnClose = false;
  #     download.panel.shown = false;
  #   };
  #   # Find all settings in about:config
  # };
}
