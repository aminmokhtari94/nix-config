{
  lib,
  fetchurl,
  runCommand,
  appimageTools,
}:

let
  pname = "twindesk";
  version = "2.0.0";
  src = fetchurl {
    url = "https://github.com/InukaAsith/TwinDesk/releases/download/v${version}/TwinDesk-${version}-x86_64.AppImage";
    hash = "sha256-mLtoN50FCZrcu7z3AQdZqMXJn50iD13bqxdFG3uPjcw=";
  };
  extracted = appimageTools.extractType2 { inherit pname version src; };
  # v2.0.0's phone-bridge.js uses `path`/`fs` without requiring them: startHost throws
  # after binding 47800, and every retry then fails with EADDRINUSE and drops the link.
  appimageContents = runCommand "${pname}-${version}-patched" { } ''
    cp -a ${extracted} $out
    chmod -R u+w $out
    f=$out/resources/app/linux/phone-bridge.js
    grep -q "require('path')" $f || sed -i "/^const { EventEmitter } = require('events');/a const fs = require('fs');\nconst path = require('path');" $f
    grep -q "require('path')" $f
  '';
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraInstallCommands = ''
    desktop=$(find ${appimageContents} -maxdepth 1 -name '*.desktop' | head -n1)
    if [ -n "$desktop" ]; then
      install -Dm444 "$desktop" $out/share/applications/${pname}.desktop
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
