{
  writeShellScriptBin,
  curl,
  hyprland,
  hyprpaper,
  jq,
  wofi,
}:

let
  wallpaperDir = "$HOME/Pictures";
in
writeShellScriptBin "wallpaper-manager" ''
  HYPRCTL=${hyprland}/bin/hyprctl
  HYPRPAPER=${hyprpaper}/bin/hyprpaper

  mkdir -p ${wallpaperDir}
  DP=$("$HYPRCTL" monitors -j | ${jq}/bin/jq -r '.[] | select(.focused) | .name')
  if [[ -z "$DP" ]]; then
    echo "Could not find focused Hyprland monitor" >&2
    exit 1
  fi

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

    # hyprpaper >=0.8 dropped preloading and loads images on demand, so the
    # `wallpaper` IPC request shows the freshly written file without touching
    # the other monitors. Only the focused monitor is changed.
    if "$HYPRCTL" hyprpaper wallpaper "$DP,$OUTPUT_FILE" >/dev/null 2>&1; then
      echo "Wallpaper set on $DP"
      exit 0
    fi

    # hyprpaper isn't reachable; start it (it loads all monitors from its config)
    # and wait for the IPC socket, then assert the new file on the focused one.
    if ! systemctl --user start hyprpaper.service >/dev/null 2>&1; then
      "$HYPRPAPER" >/dev/null 2>&1 &
    fi
    for _ in $(seq 1 50); do
      sleep 0.1
      if "$HYPRCTL" hyprpaper wallpaper "$DP,$OUTPUT_FILE" >/dev/null 2>&1; then
        echo "Wallpaper set on $DP"
        exit 0
      fi
    done
    echo "Wallpaper update failed: hyprpaper IPC is unavailable" >&2
    exit 1

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
