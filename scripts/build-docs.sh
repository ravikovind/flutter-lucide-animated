#!/bin/bash

# Build script for flutter_lucide_animated docs
# Builds example app for GitHub Pages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_DIR/docs"
EXAMPLE_DIR="$PROJECT_DIR/example"

echo "flutter_lucide_animated - Build Docs"
echo "====================================="
echo ""

# Parse arguments
SYNC_ICONS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --sync)
      SYNC_ICONS=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./build-docs.sh [--sync]"
      echo "  --sync  Sync icons from pqoqubbw/icons before building"
      exit 1
      ;;
  esac
done

# Sync icons if requested
if [ "$SYNC_ICONS" = true ]; then
  echo "Syncing icons..."
  cd "$SCRIPT_DIR"
  npm install
  node sync.js
  echo ""
fi

# Build Flutter web example
echo "Building Flutter web example..."
cd "$EXAMPLE_DIR"

# Get dependencies
flutter pub get

# Build for web with correct base href for GitHub Pages
flutter build web --release --base-href "/flutter-lucide-animated/"

echo ""
echo "Copying build to docs folder..."

# Clear docs folder and copy new build
rm -rf "$DOCS_DIR"/*
cp -r "$EXAMPLE_DIR/build/web/"* "$DOCS_DIR/"

echo "Done!"
echo ""
echo "====================================="
echo "Docs built successfully!"
echo ""
echo "Files in docs/:"
ls -la "$DOCS_DIR"
echo ""
echo "To preview locally:"
echo "  cd $DOCS_DIR && python -m http.server 8000"
echo ""
echo "Live URL: https://ravikovind.github.io/flutter-lucide-animated/"
