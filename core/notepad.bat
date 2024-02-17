@echo off
mkdir documents
:start
echo true > system\notepad.txt
cls
title Kernel OS
echo ________________________________________________________________________________________________________________________
echo.
echo                                              Nusantara OS - Notepad
echo ________________________________________________________________________________________________________________________
echo.
echo [1] Read File
echo [2] Write File
echo [3] Return Back to Kernel OS
choice /c 123 /m "Pick "
if %ERRORLEVEL% == 1 goto :read
if %ERRORLEVEL% == 2 goto :write
if %ERRORLEVEL% == 3 (
    echo true > system\notepad.dat
    call core\nusantaraos.bat
)


:read
echo true > system\notepad.txt
cls
echo ________________________________________________________________________________________________________________________
echo.
echo                                              Nusantara OS - Notepad
echo ________________________________________________________________________________________________________________________
echo.
echo [ READ FILE ONLY MODE ]
echo.
echo Include extensions ( .txt .log etc )
echo.
set /p rfile="Filename -> "
cls
echo ________________________________________________________________________________________________________________________
echo.
echo                                              Nusantara OS - Notepad
echo ________________________________________________________________________________________________________________________
echo.
echo Reading file %rfile%
echo.
type "core\documents\%rfile%"
pause >nul
goto :start


:write
echo true > system\notepad.txt
cls
echo ________________________________________________________________________________________________________________________
echo.
echo                                              Nusantara OS - Notepad
echo ________________________________________________________________________________________________________________________
echo.
echo Include extensions (.txt, etc)
echo.
set /p filename="Filename -> "  
set file="%filename%"
cls
echo ________________________________________________________________________________________________________________________
echo.
echo                                              Nusantara OS - Notepad
echo ________________________________________________________________________________________________________________________
echo.
echo To add another line to your text press enter.
echo.
echo Cannot use symbols: "> < |"
echo.
echo _____________________________________________
:edit
set /p content="-> "
if "%content%" == "exit" (
    goto :start
) else (
    echo %content% >> "core\documents\%filename%"
    goto :edit
)
cls
