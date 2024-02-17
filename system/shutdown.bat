@echo off
title Kernel OS
echo Closing all apps
ping localhost -n 3 >nul
echo [%date%] Kernel OS Shuttedown at %time% >> logs\logs.txt
exit