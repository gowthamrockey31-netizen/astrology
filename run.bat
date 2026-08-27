@echo off
echo ==============================================
echo AstroDashaCare - Starting Flutter Web
echo ==============================================

:: Terminate any hanging dart or chrome debug instances
taskkill /F /IM dart.exe >nul 2>&1

:: Remove Read-Only / OneDrive sync attributes from build folder
attrib -r -s -h /s /d build >nul 2>&1
attrib -r -s -h /s /d .dart_tool >nul 2>&1

:: Clean build directory if needed
rmdir /s /q build >nul 2>&1

:: Run Flutter on Chrome in release mode (bypasses DDS debug service hanging and runs ultra fast)
flutter run -d chrome --release
