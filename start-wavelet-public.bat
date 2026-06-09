@echo off
setlocal

cd /d "%~dp0"

if not exist "lavalink\Lavalink.jar" (
  echo Missing lavalink\Lavalink.jar
  pause
  exit /b 1
)

if not exist "backend\server.js" (
  echo Missing backend\server.js
  pause
  exit /b 1
)

if not exist "tools\cloudflared.exe" (
  echo Missing tools\cloudflared.exe
  echo Ask Codex to set up Cloudflare Tunnel again.
  pause
  exit /b 1
)

echo Starting Lavalink...
start "Wavelet Lavalink" /D "%~dp0lavalink" java -jar Lavalink.jar

timeout /t 8 /nobreak >nul

echo Starting Wavelet backend...
start "Wavelet Backend" /D "%~dp0backend" node server.js

timeout /t 4 /nobreak >nul

echo.
echo Starting Cloudflare Tunnel...
echo.
echo Copy the trycloudflare.com URL shown below and use it in the app as:
echo   https://YOUR-TUNNEL.trycloudflare.com/api
echo.
echo Keep this window open while using Wavelet on mobile data.
echo Close this window or run stop-wavelet-public.bat to stop the tunnel.
echo.

"%~dp0tools\cloudflared.exe" tunnel --url http://localhost:3000

endlocal
