{
  pkgs,
  mkShell,
  inputs,
  ...
}:

let
  android-sdk = inputs.android-nixpkgs.sdk.${pkgs.system} (
    sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
      platform-tools
      build-tools-34-0-0
      platforms-android-35
      ndk-26-3-11579264
      cmake-3-22-1
    ]
  );
in
mkShell {
  buildInputs = with pkgs; [
    android-sdk
    gradle
    openjdk
    flutter
  ];
}
