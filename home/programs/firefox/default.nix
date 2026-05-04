{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;

    languagePacks = ["en-GB"];

    policies = {
      # Updates
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # Bloat Features
      DisableFirefoxStudies = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      GenerativeAI.Enabled = false;
      GenerativeAI.Locked = true;
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = false;
        MoreFromMozilla = false;
      };

      FirefoxHome = {
        SponsoredTopSites = false;
        SponsoredPocket = false;
        Highlights = false;
      };

      # We have 1Password for this
      OfferToSaveLogins = false;
      DisableFormHistory = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      ExtensionSettings = let
        moz = short: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
          installation_mode = "force_installed";
        };
      in {
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = moz "1password-x-password-manager";
        "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = moz "augmented-steam";
        "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" = moz "auto-tab-discard";
        "@contain-facebook" = moz "facebook-container";
        "panorama-tab-groups@example.com" = moz "panorama-tab-groups";
        "jid1-xUfzOsOFlzSOXg@jetpack" = moz "reddit-enhancement-suite";
        "firefox@getsharex.com" = moz "sharex";
        "sponsorBlocker@ajay.app" = moz "sponsorblock";
        "firefox-extension@steamdb.info" = moz "steam-database";
        "tab-counter@daawesomep.addons.mozilla.org" = moz "tab-counter-webext";
        "izer@camelcamelcamel.com" = moz "the-camelizer-price-history-ch";
        "uBlock0@raymondhill.net" = moz "ublock-origin";
        "wappalyzer@crunchlabz.com" = moz "wappalyzer";
      };
    };
    profiles.default = {
      search = {
        force = true;
        default = "kagi";

        engines = {
          kagi = {
            name = "Kagi";
            urls = [
              {
                template = "https://kagi.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            iconMapObj."32" = "https://kagi.com/favicon-32x32.png";
            definedAliases = ["@k"];
          };
          nix-packages = {
            name = "Nix Packages";
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };

          nixos-wiki = {
            name = "NixOS Wiki";
            urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
            iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
            definedAliases = ["@nw"];
          };

          bing.metaData.hidden = true;
          google.metaData.hidden = true;
        };
      };
    };
  };
}
