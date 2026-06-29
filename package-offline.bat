@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0package-offline.ps1"
exit /b %ERRORLEVEL%
