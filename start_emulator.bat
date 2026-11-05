@echo off

set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk

echo Starting Android Emulator...

start "" "%ANDROID_HOME%\emulator\emulator.exe" -avd Pixel_7_Pro

exit