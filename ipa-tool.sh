#!/bin/bash

# REQUIREMENTS: MacOS, brew install ideviceinstaller
# > Installs first valid .ipa to connected iPhone
# > Uninstalls app with specified bundle

START=$(date +%s.%3N)
ts() {
  now=$(date +%s.%3N)
  delta=$(echo "$now - $START" | bc)
  printf "[ts=%.2f] " "$delta"
}

help() {
  echo "usage:"
  echo "  ipa-tool.sh install [path]"
  echo "  ipa-tool.sh delete <bundle-id>"
  exit 1
}

MODE="$1"
[[ -z "$MODE" ]] && help

if [[ "$MODE" == "install" ]]; then
  TARGET_DIR="${2:-$(pwd)}"
  cd "$TARGET_DIR" || exit 1

  APP_PATHS=($(find . -type d -name "*.app" | grep -v Simulator | grep -v "Index.noindex"))
  [[ ${#APP_PATHS[@]} -eq 0 ]] && { ts; echo "no .app found in $TARGET_DIR"; exit 1; }

  ts; echo "available .app bundles:"
  for path in "${APP_PATHS[@]}"; do
    ts; echo "$path"
  done

  APP_PATH="${APP_PATHS[0]}"
  APP_NAME=$(basename "$APP_PATH" .app)

  ts; echo "selected app: $APP_NAME"
  ts; echo "cleaning up"

  rm -rf Payload "$APP_NAME.ipa"
  mkdir Payload
  cp -r "$APP_PATH" Payload/

  ts; echo "zipping ipa"
  zip -qr "$APP_NAME.ipa" Payload
  rm -rf Payload

  ts; echo "installing to device"
  ideviceinstaller -i "$APP_NAME.ipa"

elif [[ "$MODE" == "delete" ]]; then
  BUNDLE_ID="$2"
  [[ -z "$BUNDLE_ID" ]] && help
  ts; echo "uninstalling $BUNDLE_ID"
  ideviceinstaller -U "$BUNDLE_ID"
else
  help
fi

END=$(date +%s)
ELAPSED=$(echo "$END - ${START%.*}" | bc)
ts; echo "finished in ${ELAPSED}s."
