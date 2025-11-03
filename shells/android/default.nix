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
      platforms-android-34
    ]
  );
in
mkShell {
  buildInputs = with pkgs; [
    android-sdk
    gradle
    openjdk
    nodejs
    pnpm
  ];
}
