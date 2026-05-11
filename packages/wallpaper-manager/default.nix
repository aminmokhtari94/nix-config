{
  writeShellScriptBin,
  curl,
  jq,
  wofi,
}:

let
  wallpaperDir = "$HOME/Pictures";
in
writeShellScriptBin "wallpaper-manager" ''
  mkdir -p ${wallpaperDir}
  DP=$(hyprctl monitors | awk '/Monitor/{monitor=$2} /focused: yes/{print monitor}')
  if [[ "$1" == "download" ]]; then
    echo "Downloading Bing 4K wallpaper..."
    # Bing exposes the last 8 daily images via HPImageArchive; pick one at random.
    IDX=$(( RANDOM % 8 ))
    META_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=$IDX&n=1&mkt=en-US"
    URLBASE=$(${curl}/bin/curl -sSL "$META_URL" | ${jq}/bin/jq -r '.images[0].urlbase // empty')
    if [[ -z "$URLBASE" ]]; then
      echo "Download failed: could not fetch Bing image metadata" >&2
      exit 1
    fi
    # `_UHD.jpg` suffix returns the 3840x2160 (4K) variant.
    IMAGE_URL="https://www.bing.com$URLBASE"_UHD.jpg

    OUTPUT_FILE="${wallpaperDir}/wallpaper-$DP.jpg"
    TMP_FILE="$(mktemp -t wallpaper.XXXXXX)"
    trap 'rm -f "$TMP_FILE"' EXIT

    HTTP_CODE=$(${curl}/bin/curl -sSL -w '%{http_code}' -o "$TMP_FILE" "$IMAGE_URL")
    if [[ "$HTTP_CODE" != "200" ]]; then
      echo "Download failed: HTTP $HTTP_CODE" >&2
      exit 1
    fi

    SIZE=$(stat -c %s "$TMP_FILE")
    if (( SIZE < 10240 )); then
      echo "Download failed: file is only $SIZE bytes (likely a geoblock/error page)" >&2
      exit 1
    fi

    # JPEG magic bytes: FF D8 FF
    MAGIC=$(head -c 3 "$TMP_FILE" | od -An -tx1 | tr -d ' \n')
    if [[ "$MAGIC" != "ffd8ff" ]]; then
      echo "Download failed: not a valid JPEG (magic=$MAGIC)" >&2
      exit 1
    fi

    mv "$TMP_FILE" "$OUTPUT_FILE"
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
