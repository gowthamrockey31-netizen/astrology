@echo off
echo ==============================================
echo Astro - Starting Flutter Web in Chrome
echo ==============================================

:: Remove Read-Only / OneDrive sync attributes from build folder
attrib -r -s -h /s /d build >nul 2>&1

:: Clean build directory
rmdir /s /q build >nul 2>&1

:: Run Flutter on Chrome
flutter run -d chrome
