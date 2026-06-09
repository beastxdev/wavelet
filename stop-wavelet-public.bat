@echo off
setlocal

echo Stopping Wavelet public stack...

taskkill /IM cloudflared.exe /F >nul 2>nul
taskkill /IM node.exe /F >nul 2>nul
taskkill /IM java.exe /F >nul 2>nul

echo.
echo Stopped Cloudflare Tunnel, backend, and Lavalink.
echo.
pause

endlocal
