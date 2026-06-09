@echo off
setlocal

cd /d "%~dp0"

echo Stopping Gradle daemons...
cd android
call gradlew --stop
cd ..

echo Cleaning Flutter and Android build caches...
call flutter clean

if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"

echo Fetching packages...
call flutter pub get

echo Done. Now run:
echo flutter build apk --release --split-per-abi --no-tree-shake-icons
pause

endlocal
