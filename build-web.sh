#!/usr/bin/env bash
cd frontend
flutter build web --web-renderer canvaskit
cd ..
rm -r web_build
mkdir web_build
cp -ra frontend/build/web/. web_build
