@echo off
mode 122,30

echo.
echo                                                Starting Nusantara OS
echo                                          [======       ] 25% [              ]
echo                                                    Checking Files
ping localhost -n 2 >nul
cls
echo.
echo                                                Starting Nusantara OS
echo                                          [=============] 50% [              ]
echo                                                   Checking Updates
ping localhost -n 2 >nul
cls
echo.
echo                                                Starting Nusantara OS
echo                                          [=============] 80% [=========    ]
echo                                                       Finishing
ping localhost -n 1 >nul
cls
echo.
echo                                                Starting Nusantara OS
echo                                          [=============] 100% [=============]
echo                                                       Launching
ping localhost -n 2 >nul
call core\nusantaraos.bat