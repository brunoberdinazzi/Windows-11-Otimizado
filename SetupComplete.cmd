@echo off
setlocal
echo [%date% %time%] SetupComplete: iniciando >> "%WINDIR%\Setup\Scripts\debloat.log"

REM Rodar debloat
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%WINDIR%\Setup\Scripts\debloat.ps1" >> "%WINDIR%\Setup\Scripts\debloat.log" 2>&1

echo [%date% %time%] SetupComplete: concluido >> "%WINDIR%\Setup\Scripts\debloat.log"
endlocal
exit /b 0
