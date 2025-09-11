{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "mqtt-explorer";
  version = "0.4.0-beta.6";

  src = fetchurl {
    url =
      "https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v0.4.0-beta.6/MQTT-Explorer-0.4.0-beta.6.AppImage";
    sha256 =
      "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # run nix-prefetch-url to fill
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/mqtt-explorer
    chmod +x $out/bin/mqtt-explorer
  '';

  meta = with lib; {
    description = "Prebuilt MQTT Explorer AppImage";
    homepage = "https://github.com/thomasnordquist/MQTT-Explorer";
    license = licenses.cc-by-nd-40;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mqtt-explorer";
  };
}
