@echo off
setlocal enabledelayedexpansion

echo Creating DeX virtual display...
adb shell settings put global overlay_display_devices none
adb shell settings put global overlay_display_devices 1920x1200/200
timeout /t 2 /nobreak >nul

echo Detecting active DeX display ID...
set "DEX_ID="

:: Parse display IDs and grab the secondary one (non-zero)
for /f "tokens=2 delims==" %%A in ('scrcpy --list-displays 2^>^&1 ^| findstr /C:"--display-id="') do (
    for /f "tokens=1" %%B in ("%%A") do (
        if not "%%B"=="0" (
            set "DEX_ID=%%B"
        )
    )
)

if "%DEX_ID%"=="" (
    echo [ERROR] Could not detect a secondary display ID.
    goto cleanup
)

echo Found DeX Display ID: !DEX_ID!
echo Starting DeX session...

:: Launch scrcpy targeting the dynamically found ID
scrcpy --display-id=!DEX_ID! -w -M -K -b 16M --max-fps=60 --no-audio

:cleanup
echo.
echo Closing DeX and cleaning up virtual display...
adb shell settings put global overlay_display_devices none
echo Complete!
endlocal
