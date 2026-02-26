#!/bin/sh
# Fix package_config.json so package:flutter_kitten_tts resolves when the project
# directory is named kitten_tts_flutter. Run after `flutter pub get` if you see
# "Target of URI doesn't exist: package:flutter_kitten_tts/...".
cd "$(dirname "$0")/.."
cfg=".dart_tool/package_config.json"
if [ ! -f "$cfg" ]; then
  echo "Run flutter pub get first."
  exit 1
fi
# Only the root package has rootUri "../" here; change to ".." so resolution works.
if grep -q '"rootUri": "../"' "$cfg"; then
  sed -i.bak 's|"rootUri": "../"|"rootUri": ".."|' "$cfg" 2>/dev/null || sed -i '' 's|"rootUri": "../"|"rootUri": ".."|' "$cfg"
  rm -f "${cfg}.bak"
  echo "Fixed. Run dart analyze to verify."
else
  echo "No change needed."
fi
