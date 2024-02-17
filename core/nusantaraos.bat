@echo off
chcp 65001
mode 122,30
cls
title Nusantara OS (4.2.24b-dev)
cls
if exist system\notepad.txt==del system\notepad.txt && goto :nsos
if not exist system\apps\nircmd.exe==set excom=nircmd.exe & set stopcode=0x01 & goto BSOD
if not exist system\apps\cmdmenusel.exe==set excom=cmdmenusel.exe & set stopcode=0x02 & goto BSOD
if not exist system\apps\sound.exe==set excom=sound.exe & set stopcode=0x03 & goto BSOD
if not exist system\sounds\Ding.wav==set excom=Ding.wav & set stopcode=0x04 & goto BSOD
if not exist system\sounds\bsod.wav==set excom=bsod.wav & set stopcode=0x05 & goto BSOD
if not exist system\sounds\alarm.wav==set excom=alarm.wav & set stopcode=0x06 & goto BSOD

:::::::::::::::
:: Variables ::
:::::::::::::::

set "build=10.2.24"
set "osbuild=10.2.24b-dev"
set "codename=Lexa"
set "excom=N/A"
set "ram=4096"

:: ________________________________________________________________________________________________________________________

if not exist system\login_info.txt==goto :makelogin
goto login

:: ________________________________________________________________________________________________________________________


:makelogin
cls
type system\asukaid.txt
echo.
echo                                     No AsukaID Detected. Please make a new one.
echo.
echo.
set /p user=[Asuka4k] AsukaID Name : 
set /p pass=[Asuka4k] AsukaID Pass : 
goto :makelogin
:: ________________________________________________________________________________________________________________________
:login
cls
<system\login_info.txt (
set /p AsukaIDN=
set /p AsukaIDP=
)
type system\asukaid.txt
echo.
echo                                        Please enter your AsukaID Information.
echo.
set /p user2=[Asuka4k] AsukaID Name : 
if not %user2% == %AsukaIDN% goto :loginfail
set /p pass2=[Asuka4k] AsukaID Pass : 
if not %pass2% == %AsukaIDP% goto :loginfail
goto :nsos1
:: ________________________________________________________________________________________________________________________
:loginfail
cls
<system\login_info.txt (
set /p AsukaIDN=
set /p AsukaIDP=
)
type system\asukaid.txt
echo.
echo                                       Please enter your AsukaID Information.
echo.
echo                   [!] The entered AsukaID Name or AsukaID Password is incorrect. Please try again. [!]
echo.
echo.
set /p user2=[Asuka4k] AsukaID Name : 
if not %user2% == %AsukaIDN% goto :loginfail
set /p pass2=[Asuka4k] AsukaID Pass : 
if not %pass2% == %AsukaIDP% goto :loginfail
goto :nsos1
:: ________________________________________________________________________________________________________________________
:BSOD
cls
color c
echo [%date% at %time%] Nusantara OS has ran a problem with %excom% >> logs\logs.txt
system\apps\sound.exe play system\sounds\bsod.wav
echo.
echo :(
echo.
echo Nusantara OS ran into a problem
echo Recovery Terminal will launch automatically for you
echo.
echo the bsod log has been saved at logs\logs.txt
echo.
echo what failed: %excom%
echo stopcode: %stopcode%
ping localhost -n 6 >nul
cls
call sysfail/recovery.bat


:nsos1
if not exist system\license.txt==goto :licss
cls
echo Select Menu:
system\apps\cmdMenuSel.exe f8%f0 "Continue to OS" "Sound Settings" "Apps" "Install Apps" "Version" "Exit OS"
if %errorlevel% == 1 goto nsos
if %errorlevel% == 2 goto sndset
if %errorlevel% == 3 goto apps
if %errorlevel% == 4 goto insapps
if %errorlevel% == 5 (
	cls
	goto ver
)
if %errorlevel% == 6 (
	cls
	echo Closing All Apps...
	taskkill /f /im sound.exe
	ping localhost -n 2 >nul
	exit
)
goto nsos


:nsos
title Nusantara OS (4.2.24b-dev)
cls
echo.
type system\playtxt.txt
echo.
echo.
echo Nusantara OS (4.2.24b-dev)
echo.
echo Current date: %date%
echo Current time: %time%
echo.
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
if %terminal% == draw call system\apps\draw\draw.bat
::if %terminal% == timer goto timer
if %terminal% == time goto time
if %terminal% == sysinfo goto sysinfo
if %terminal% == vol goto vol
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto pgos


:sndset
cls
echo Volume (in %%) :
cmdMenuSel f8%f0 "Go back" "100" "90" "80" "70" "60" "50" "40" "30" "20" "10" "0"
if %ERRORLEVEL% == 1 goto pgos1
if %ERRORLEVEL% == 2 system\apps\cmdmenusel\nircmd.exe setsysvolume 65535 & sound play sounds\ding.wav
if %ERRORLEVEL% == 3 system\apps\cmdmenusel\nircmd.exe setsysvolume 58982 & sound play sounds\ding.wav
if %ERRORLEVEL% == 4 system\apps\cmdmenusel\nircmd.exe setsysvolume 52429 & sound play sounds\ding.wav
if %ERRORLEVEL% == 5 system\apps\cmdmenusel\nircmd.exe setsysvolume 45876 & sound play sounds\ding.wav
if %ERRORLEVEL% == 6 system\apps\cmdmenusel\nircmd.exe setsysvolume 39323 & sound play sounds\ding.wav
if %ERRORLEVEL% == 7 system\apps\cmdmenusel\nircmd.exe setsysvolume 32770 & sound play sounds\ding.wav
if %ERRORLEVEL% == 8 system\apps\cmdmenusel\nircmd.exe setsysvolume 26217 & sound play sounds\ding.wav
if %ERRORLEVEL% == 9 system\apps\cmdmenusel\nircmd.exe setsysvolume 19664 & sound play sounds\ding.wav
if %ERRORLEVEL% == 10 system\apps\cmdmenusel\nircmd.exe setsysvolume 13111 & sound play sounds\ding.wav
if %ERRORLEVEL% == 11 system\apps\cmdmenusel\nircmd.exe setsysvolume 6558 & sound play sounds\ding.wav
if %ERRORLEVEL% == 12 system\apps\cmdmenusel\nircmd.exe setsysvolume 1 & sound play sounds\ding.wav
goto sndset

:help
title Nusantara OS (4.2.24b-dev)
echo Showing Commands
echo.
echo * Basics:
echo [help]       - Shows all available commands
echo [time]       - Shows current time
echo [date]       - Shows current date
echo [shutdown]   - Shuts down os
echo [soundplay]  - Plays sound
echo [soundstop]  - Stops sound
echo [clear]      - Clears screen
echo.
echo * Nusa Apps:
echo [calculator] - Math
echo [draw]       - Basically Paint.exe (currently unsupports going back to Nusantara OS)
echo.
echo * Miscellaneous:
echo [panel]      - Control Panel
echo [sysinfo]    - Shows information about the system
echo [vol]        - Displays a Disk Information
echo [ver]        - Shows OS Information
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == sysinfo goto sysinfo
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == date goto date
if %terminal% == vol goto vol
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto help

:timer
title Nusantara OS (4.2.24b-dev)
echo Type a number between `1 - Unlimited` to begin the timer
set /p timer2=
echo Press any key to start timer
pause >nul
timeout %timer2%
echo Playing alarm sound
system\apps\sound.exe play sounds\alarm.wav
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
if %terminal% == vol goto vol
::if %terminal% == timer goto timer
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto timer

:ver
title Nusantara OS (4.2.24b-dev)
echo.
echo.
echo Nusantara OS Version %build% (OS Build %osbuild%)
echo Codename: %codename%
echo Copyright (C) 2022 - 2024 Asuka4k
echo.
echo The Nusantara OS is made for personal project only and should be not used in real scenario for personal purposes.
echo.
echo It would be nice if you would donate us to make this project big!
echo.
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == time goto time
if %terminal% == date goto date
if %terminal% == vol goto vol
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == sysinfo goto sysinfo
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto ver

:calc
title Nusantara OS (4.2.24b-dev)
echo.
set /p MATH="Calculator.kos (ex 1+1) -> "
set /a result=%MATH%
echo Result: %result%
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
if %terminal% == vol goto vol
::if %terminal% == timer goto timer
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == sysinfo goto sysinfo
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto calc

:bsod1
echo Exiting
ping localhost -n 2 >nul
exit

:apps
title Nusantara OS (4.2.24b-dev)
cls
echo Available Apps:
echo [notepad]        - You know it.
echo [sound]          - You also know it. Plays sound and stuff
echo [asuka4k]        - Yo its that me??
echo.
echo You can run the apps in the Terminal.
echo And this app list is outdated, you should probably use the [help] menu in the terminal instead.
echo.
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == date goto date
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == calculator goto calc
if %terminal% == vol goto vol
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto apps

:time
title Nusantara OS (4.2.24b-dev)
echo Current time: %time%
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == date goto date
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == calculator goto calc
if %terminal% == vol goto vol
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto time

:date
title Nusantara OS (4.2.24b-dev)
echo Current date: %date%
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == vol goto vol
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto date

:vol
title Nusantara OS (4.2.24b-dev)
vol
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == sysinfo goto sysinfo
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == time goto time
if %terminal% == vol goto vol
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto vol

:sysinfo
title Nusantara OS (4.2.24b-dev)
echo Total Physical Memory:     %ram% MB
echo Available Physical Memory: %ram% MB
echo.
echo BIOS Version:              Asuka X-14, 2/14/2024
echo Nusantara OS Directory:       %cd%
echo System Manufacturer:       FYNX COMPUTER INC.
echo System Model:              FYNX_Asuka X-14JB
echo System Type:               x64-based PC
echo Processor(s):              2
echo System Directory:          %cd%\system
echo Boot Device:               %cd%\system
echo System Locale:             en-us English (United States)
echo Input Locale:              en-us English (United States)
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == vol goto vol
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto sysinfo

:soundplay
title Nusantara OS (4.2.24b-dev)
echo.
set /p song=Sound.kos (ex. example.wav) = 
echo Playing!
system\apps\sound.exe play %song%
echo.
echo Use [soundstop] to stop the sound.
echo.
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == vol goto vol
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto soundplay

:soundstop
title Nusantara OS (4.2.24b-dev)
echo.
echo Stopping Sound!
taskkill /f /im sound.exe
echo Stopped successfully.
echo.
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == vol goto vol
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto soundstop

:clear
title Nusantara OS (4.2.24b-dev)
cls
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == vol goto vol
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto soundstop

:insapps
cls
echo.
echo.
echo.
echo This feature is undergoing maintenance.
echo.
set /p terminal=nusantara@os:~$ 
if %terminal% == notepad call notepad.bat
if %terminal% == help goto help
::if %terminal% == timer goto timer
if %terminal% == sysinfo goto sysinfo
if %terminal% == time goto time
if %terminal% == draw call system\apps\draw\draw.bat
if %terminal% == vol goto vol
if %terminal% == date goto date
if %terminal% == calculator goto calc
if %terminal% == panel goto pgos1
if %terminal% == shutdown goto bsod1
if %terminal% == ver goto ver
if %terminal% == soundplay goto soundplay
if %terminal% == soundstop goto soundstop
if %terminal% == clear goto clear
goto insapps