{pkgs, ...}: {
  # iPhone/iPad over USB. usbmuxd is the multiplexing daemon everything else
  # talks to - it also ships the udev rules that let the user access the
  # device without root. Without it the phone shows up as a USB device but
  # no file manager or tool can reach it.
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2; # more reliable with recent iOS than usbmuxd 1.x
  };

  # gvfs (already on via GNOME) provides the gvfsd-afc backend, so Nautilus /
  # Dolphin show the phone automatically. ifuse is the CLI counterpart for a
  # real mountpoint; userAllowOther lets root-visible tools read the mount.
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    libimobiledevice # ideviceinfo, idevicepair, idevicebackup2, ...
    ifuse # mount the phone's media/app dirs as a filesystem
  ];
}
