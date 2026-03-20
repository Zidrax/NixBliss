{ config, pkgs, inputs, username, hostname, ... }:

{
  # Firefix  
  programs.firefox = {
    enable = true;
    profiles.User = {
      isDefault = true;

      settings = {
        # --- ВОССТАНОВЛЕНИЕ СЕССИИ (Твои вкладки) ---
        "browser.startup.page" = 3;               # 3 = Восстанавливать предыдущую сессию
        "browser.startup.homepage" = "about:blank"; # Новое окно всё равно будет чистым

        # --- ПАРОЛИ (Раз ты ими пользуешься) ---
        "signon.rememberSignons" = true;          # Вернул возможность сохранять пароли

        # --- МИНИМАЛИЗМ (Оставляем как было) ---
        "browser.newtabpage.enabled" = false;
        "extensions.pocket.enabled" = false;
        "browser.tabs.firefox-view" = false;
        "browser.aboutConfig.showWarning" = false;

        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.vpn_promo.enabled" = false;
        "browser.promo.focus.enabled" = false;

        "places.history.enabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "datareporting.healthreport.uploadEnabled" = false;
      };
    };
  };

}

