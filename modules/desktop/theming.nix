{ pkgs, ... }:

{
  boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
    pname = "distro-grub-themes";
    version = "3.1";
    src = pkgs.fetchFromGitHub {
      owner = "AdisonCavani";
      repo = "distro-grub-themes";
      rev = "v3.1";
      hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
    };
    installPhase = "cp -r customize/nixos $out";
  };

  xdg.mime.defaultApplications = {
    "image/jpeg" = [ "image-roll.desktop" "feh.desktop" ];
    "image/png" = [ "image-roll.desktop" "feh.desktop" ];
    "text/plain" = "org.gnome.gedit.desktop";
    "text/html" = "brave-browser.desktop";
    "text/csv" = "org.gnome.gedit.desktop";
    "application/pdf" = "brave-browser.desktop";
    "application/zip" = "org.gnome.FileRoller.desktop";
    "application/x-tar" = "org.gnome.FileRoller.desktop";
    "application/x-bzip2" = "org.gnome.FileRoller.desktop";
    "application/x-gzip" = "org.gnome.FileRoller.desktop";
    "x-scheme-handler/http" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/https" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/about" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "brave-browser.desktop" "firefox.desktop" ];
    "x-scheme-handler/mailto" = [ "brave-browser.desktop" ];
    "audio/mp3" = "vlc.desktop";
    "audio/x-matroska" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/mp4" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
  };
}
