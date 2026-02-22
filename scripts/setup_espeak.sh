#!/bin/bash
# Downloads and prepares espeak-ng source for building as part of the plugin.
# Run this once after cloning the repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ESPEAK_DIR="$ROOT_DIR/third_party/espeak-ng"
ESPEAK_VERSION="1.52.0"
ESPEAK_TAG="1.52.0"

echo "=== KittenTTS: Setting up espeak-ng ==="

if [ -d "$ESPEAK_DIR" ] && [ -f "$ESPEAK_DIR/src/include/espeak-ng/speak_lib.h" ]; then
  echo "espeak-ng source already present at $ESPEAK_DIR"
  exit 0
fi

echo "Downloading espeak-ng $ESPEAK_VERSION source..."
mkdir -p "$ROOT_DIR/third_party"
cd "$ROOT_DIR/third_party"

if [ -f "espeak-ng-${ESPEAK_TAG}.tar.gz" ]; then
  echo "Archive already downloaded."
else
  curl -L -o "espeak-ng-${ESPEAK_TAG}.tar.gz" \
    "https://github.com/espeak-ng/espeak-ng/archive/refs/tags/${ESPEAK_TAG}.tar.gz"
fi

echo "Extracting..."
tar xzf "espeak-ng-${ESPEAK_TAG}.tar.gz"
mv "espeak-ng-${ESPEAK_TAG}" espeak-ng

echo "=== espeak-ng source ready at $ESPEAK_DIR ==="
echo ""
echo "Source files:  $ESPEAK_DIR/src/"
echo "Headers:       $ESPEAK_DIR/src/include/"
echo ""
echo "Now you can build the Flutter plugin normally."
