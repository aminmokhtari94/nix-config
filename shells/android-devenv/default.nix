{
  pkgs,
  inputs,
  ...
}:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    (
      { pkgs, config, ... }:
      {
        android = {
          enable = true;
          platforms.version = [
            "35"
          ];
          systemImageTypes = [ "google_apis_playstore" ];
          abis = [
            "arm64-v8a"
            # "x86_64"
          ];
          # cmake.version = [ "3.22.1" ];
          # cmdLineTools.version = "13.0";
          # tools.version = "26.1.1";
          # platformTools.version = "36.0.1";
          # buildTools.version = [ "35.0.0" ];
          emulator = {
            enable = false;
            # version = "34.1.9";
          };
          # sources.enable = false;
          # systemImages.enable = true;
          ndk.enable = true;
          ndk.version = [ "26.3.11579264" ];
          # googleAPIs.enable = true;
          # googleTVAddOns.enable = true;
          extras = [ "extras;google;gcm" ];
          extraLicenses = [
            "android-sdk-preview-license"
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
          android-studio = {
            enable = false;
            package = pkgs.android-studio;
          };
          flutter.enable = true;
        };
      }
    )
  ];
}
