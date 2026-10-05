# SearXNG: private meta search engine, http://127.0.0.1:8080
# Toggle: my.searxng.enable (modules/nixos/profiles.nix)
#
# Native NixOS service (not a container). Also the web-search backend for
# Odysseus and Open WebUI. It queries other engines from the server and
# merges their results; nothing is tracked and no browser cookies are used.
#
# Engines (2026-10, tested from this connection): SearXNG's defaults plus
# Bing, Bing News and Mojeek. In practice Bing delivers most web results;
# Google returns nothing to SearXNG-style requests, and Brave, DuckDuckGo,
# Startpage, Qwant and Yahoo often rate-limit or serve captchas. SearXNG
# suspends an engine for a while after such errors and keeps going with the
# rest. Wikipedia/Wikidata add infoboxes. See which engines answered: the
# "Engines" info at the bottom of a result page, or `&format=json` ->
# "unresponsive_engines".
#
# The secret key is generated once on this machine (not stored in the repo).
{
  config,
  lib,
  pkgs,
  ...
}: let
  secretFile = "/var/lib/searxng-secret/env";
in {
  config = lib.mkIf config.my.searxng.enable {
    services.searx = {
      enable = true;
      environmentFile = secretFile;
      settings = {
        general.instance_name = "SearXNG";
        server = {
          bind_address = "127.0.0.1";
          port = 8080;
          secret_key = "$SEARX_SECRET_KEY";
          limiter = false; # local-only instance, no bot protection needed
        };
        search = {
          formats = ["html" "json"]; # json: API for Odysseus / Open WebUI
          safe_search = 0;
        };
        engines = map (name: {
          inherit name;
          disabled = false;
        }) ["bing" "bing news" "mojeek"];
      };
    };

    systemd.services.searxng-secret = {
      description = "Generate the SearXNG secret key once";
      wantedBy = ["searx-init.service"];
      before = ["searx-init.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        if [ ! -s ${secretFile} ]; then
          mkdir -p "$(dirname ${secretFile})"
          umask 077
          echo "SEARX_SECRET_KEY=$(${lib.getExe pkgs.openssl} rand -hex 32)" > ${secretFile}
        fi
      '';
    };
    systemd.services.searx-init = {
      requires = ["searxng-secret.service"];
      after = ["searxng-secret.service"];
    };
  };
}
