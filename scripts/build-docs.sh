#!/bin/bash

# Build script for flutter_lucide_animated docs
# Syncs icons and builds example for GitHub Pages

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
BUILD_EXAMPLE=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --sync)
      SYNC_ICONS=true
      shift
      ;;
    --no-example)
      BUILD_EXAMPLE=false
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./build-docs.sh [--sync] [--no-example]"
      echo "  --sync        Sync icons from pqoqubbw/icons"
      echo "  --no-example  Skip building Flutter web example"
      exit 1
      ;;
  esac
done

# Sync icons if requested
if [ "$SYNC_ICONS" = true ]; then
  echo "Syncing icons..."
  cd "$SCRIPT_DIR"
  node sync.js
  echo ""
fi

# Build Flutter web example
if [ "$BUILD_EXAMPLE" = true ]; then
  echo "Building Flutter web example..."
  cd "$EXAMPLE_DIR"

  # Clean previous build
  flutter clean

  # Build for web with correct base href for GitHub Pages
  flutter build web --release --base-href "/flutter-lucide-animated/"

  echo ""
  echo "Copying build to docs folder..."

  # Copy build to docs, preserving v1 folder
  # First, remove old web build files (but keep v1)
  find "$DOCS_DIR" -maxdepth 1 -type f -delete 2>/dev/null || true
  rm -rf "$DOCS_DIR/assets" "$DOCS_DIR/canvaskit" "$DOCS_DIR/icons" 2>/dev/null || true

  # Copy new build
  cp -r "$EXAMPLE_DIR/build/web/"* "$DOCS_DIR/"

  echo "Done!"
fi

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
