@echo off
REM QuizHub dev server launcher.
REM Starts the Node.js server at http://localhost:8088 (configurable via PORT env var).

setlocal
set "PORT=8088"

echo.
echo === QuizHub dev server ===
echo Starting on http://localhost:%PORT%
echo Press Ctrl+C to stop.
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js is not installed or not on PATH.
  echo         Install from https://nodejs.org/ and try again.
  pause
  exit /b 1
)

node "%~dp0server.js"
endlocal