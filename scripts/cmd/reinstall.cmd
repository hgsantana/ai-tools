@echo off
rem ai-tools reinstall - thin shim: all logic lives in scripts\powershell\reinstall.ps1
setlocal
set "PS1=%~dp0..\powershell\reinstall.ps1"
where pwsh >nul 2>nul
if %errorlevel%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
)
endlocal & exit /b %errorlevel%
