#!/bin/bash
set -e

echo "📦 Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"

flutter --version
flutter config --enable-web
flutter doctor

echo "🚀 Building Flutter Web..."
flutter build web
