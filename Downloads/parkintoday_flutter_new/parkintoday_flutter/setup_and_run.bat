@echo off
echo ================================================
echo  ParkInToday Flutter Setup
echo ================================================
echo.

REM Step 1: Create platform configs (this is the fix for the error)
echo [1/3] Creating platform support...
flutter create --platforms=windows,web,android,ios .

echo.
echo [2/3] Installing packages...
flutter pub get

echo.
echo [3/3] Launching app...
echo.
echo Choose your target:
echo   1. Windows desktop  (flutter run -d windows)
echo   2. Chrome browser   (flutter run -d chrome)
echo   3. Android emulator (flutter run -d android)
echo.
set /p choice="Enter 1, 2, or 3: "

if "%choice%"=="1" flutter run -d windows
if "%choice%"=="2" flutter run -d chrome
if "%choice%"=="3" flutter run -d android

pause
