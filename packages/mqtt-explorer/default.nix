{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "mqtt-explorer";
  version = "0.4.0-beta.6";
  src = fetchurl {
    url = "https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v${version}/MQTT-Explorer-${version}.AppImage";
    sha256 = "sha256-zEosMda2vtq+U+Lrvl6DExvT5cGPbDz0eJo7GRlVzVA=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Make sure the binary points directly to AppRun
    mv $out/bin/${pname} $out/bin/.wrapped-${pname}
    cat > $out/bin/${pname} <<EOF
    #!${lib.getBin lib.runtimeShell}/bin/sh
    exec $out/bin/.wrapped-${pname} "\$@"
    EOF
    chmod +x $out/bin/${pname}
  '';

  meta = with lib; {
    description = "Prebuilt MQTT Explorer AppImage (unpacked, no FUSE needed)";
    homepage = "https://github.com/thomasnordquist/MQTT-Explorer";
    license = licenses.cc-by-nd-40;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mqtt-explorer";
  };
}
