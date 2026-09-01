{pkgs, config, ...}:
{
  users.groups.copyparty = {};

  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
  };

  systemd.services.copyparty = {
    enable = true;
    description = "copyparty photo share - sailwithus";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      # User = "copyparty";
      Group = "copyparty";
      # DynamicUser = true;
      User = "maike";

      ExecStart = "${pkgs.copyparty}/bin/copyparty -p 3923 -i 127.0.0.1 -c %d/cpconf";
      LoadCredential = "cpconf:/home/maike/.config/copyparty/copyparty.conf";
      ProtectSystem = "strict";
      ReadOnlyPaths = [ /home/maike/Pictures/NIKON-ZR/2026_08_08-15_SailWithUs-Greece/100NC_ZR/shared ];
    };
  };
}

# Example config:
# [global]
#   hist: /home/maike/.cache/copyparty
#   theme: 2
#
# [accounts]
# friends_account: enter_password_here
#
# [/photos]
# /home/maike/Pictures/NIKON-ZR/2026_08_08-15_SailWithUs-Greece/100NC_ZR/shared
# accs:
# r: friends_account
# flags:
#   grid
#
