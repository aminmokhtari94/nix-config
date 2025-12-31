{
  writeShellScriptBin,
  curl,
  wofi,
}:

let
  wallpaperDir = "$HOME/Pictures";
in
writeShellScriptBin "wallpaper-manager" ''
  mkdir -p ${wallpaperDir}
  DP=$(hyprctl monitors | awk '/Monitor/{monitor=$2} /focused: yes/{print monitor}')
  if [[ "$1" == "download" ]]; then
    echo "Downloading wallpaper..."
    IMAGE_URL="https://unsplash.it/3840/2160?random"
    if [[ "$DP" == "DP-3" ]]; then
      IMAGE_URL="https://unsplash.it/2160/3840?random"
    fi
    OUTPUT_FILE="${wallpaperDir}/wallpaper-$DP.jpg"
    ${curl}/bin/curl -sSL "$IMAGE_URL" -o "$OUTPUT_FILE"
    echo "Wallpaper saved to $OUTPUT_FILE"
    hyprctl hyprpaper unload "$OUTPUT_FILE"
    hyprctl hyprpaper preload "$OUTPUT_FILE"
    hyprctl hyprpaper wallpaper "$DP,$OUTPUT_FILE"

  elif [[ "$1" == "catalog" ]]; then
    echo "Opening wallpaper catalog..."
    FILE=$(find ${wallpaperDir} -type f -name '*.jpg' | ${wofi}/bin/wofi --dmenu --prompt 'Select Wallpaper')
    if [[ -n "$FILE" ]]; then
      xdg-open "$FILE"
    fi

  else
    echo "Usage: wallpaper-manager <download|catalog>"
  fi
''
