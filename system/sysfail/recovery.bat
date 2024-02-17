@echo off
color 0f
title Kernel OS
echo.
echo Welcome to Kernel OS Recovery Terminal
echo.
:strr
set /p termin=kernel@os:~$ 
if %termin% == help goto :helpp
if %termin% == recovery goto :recoveryp
if %termin% == "exit" call kernelos.bat
goto :strr

:helpp
echo.
echo [help]      - shows existing commands in this Recovery Terminal
echo [recovery]  - fix the os errors
echo [exit]      - exits Recovery Terminal and go back to Kernel OS
set /p termin=kernel@os:~$ 
if %termin% == help goto :helpp
if %termin% == recovery goto :recoveryp
if %termin% == "exit" call kernelos.bat
goto :helpp

:recoveryp
echo.
echo Recovering
xcopy sysfail\nano.exe system\apps\ /f
xcopy sysfail\nircmd.exe system\apps\ /f
xcopy sysfail\sound.exe system\apps\ /f
xcopy sysfail\cmdmenusel.exe system\apps\ /f
xcopy sysfail\sounds\alarm.wav sounds\ /f
xcopy sysfail\sounds\bsod.wav sounds\ /f
xcopy sysfail\sounds\Ding.wav sounds\ /f
echo.
echo Done
echo.
set /p termin=kernel@os:~$ 
if %termin% == help goto :helpp
if %termin% == recovery goto :recoveryp
if %termin% == "exit" call kernelos.bat
goto :strr