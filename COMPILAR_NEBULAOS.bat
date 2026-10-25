@echo off
setlocal
chcp 65001 >nul
title Compilador de NebulaOS - nube
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\compilar-nebulaos.ps1"
echo.
pause
