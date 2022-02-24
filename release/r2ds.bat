@echo off

:choice
cls
color 9f
echo THE SERVER WILL BE AUTO START IN 10 SECONDS: Press Y to START IMMEDIATELY or N to STOP the server
choice /c yn /d y /t 10

set _e=%ERRORLEVEL%
if %_e%==1 goto :start
if %_e%==2 goto :exit
echo Error
goto :choice

:exit
ECHO Closing the server
color 4f
timeout 2 > NUL
exit

:start
cls
ECHO Server Starting
color 0f
NorthstarLauncher.exe -dedicated -multiple
ECHO Server Closed / Crashed
color 6f
timeout 2 > NUL
goto choice
