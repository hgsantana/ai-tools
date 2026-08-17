@echo off
rem ai-tools remove - thin shim: all logic lives in scripts\powershell\remove.ps1
setlocal
set "PS1=%~dp0..\powershell\remove.ps1"
where pwsh >nul 2>nul
if %errorlevel%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
)
endlocal & exit /b %errorlevel%
