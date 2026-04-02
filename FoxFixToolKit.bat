@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%0' -Verb RunAs"
    exit /b
)

title FoxFix ToolKit
echo Pobieranie skryptu...
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm 'https://code.foxfix.it/fft.ps1')"