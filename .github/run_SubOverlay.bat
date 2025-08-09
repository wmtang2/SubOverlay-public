@echo off
echo Starting SubOverlay...
SubOverlay.exe
if errorlevel 1 (
  pause
)
