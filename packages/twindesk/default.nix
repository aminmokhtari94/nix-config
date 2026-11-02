{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "twindesk";
  version = "2.0.0";
  src = fetchurl {
    url = "https://github.com/InukaAsith/TwinDesk/releases/download/v${version}/TwinDesk-${version}-x86_64.AppImage";
    hash = "sha256-mLtoN50FCZrcu7z3AQdZqMXJn50iD13bqxdFG3uPjcw=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    desktop=$(find ${appimageContents} -maxdepth 1 -name '*.desktop' | head -n1)
    if [ -n "$desktop" ]; then
      install -Dm444 "$desktop" $out/share/applications/${pname}.desktop
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-quiet 'Exec=AppRun' 'Exec=${pname}'
      sed -i 's|^Exec=[^ ]*|Exec=${pname}|' $out/share/applications/${pname}.desktop
    fi
    if [ -d ${appimageContents}/usr/share/icons ]; then
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = with lib; {
    description = "Share one mouse, keyboard, clipboard and files across Mac, Windows, Linux and Android";
    homepage = "https://github.com/InukaAsith/TwinDesk";
    license = licenses.free;
    platforms = [ "x86_64-linux" ];
    mainProgram = "twindesk";
  };
}
