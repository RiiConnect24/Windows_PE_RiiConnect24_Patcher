echo off
cls
echo.
echo Please wait...
echo Initiating the preboot environment...
echo.
echo RiiConnect24 Patcher will start shortly...
wpeinit>NUL

set FilesHostedOn=https://kcrPL.github.io/Patchers_Auto_Update/RiiConnect24Patcher
cd/
cd RiiConnect24

:: Trying to download RC24 Patcher.

:1

curl -f -L -s -S --insecure "%FilesHostedOn%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
if not %errorlevel%==0 goto 1_error_no_internet

call "update_assistant.bat" -RC24_Patcher -preboot

call RiiConnect24Patcher.bat -preboot

goto 1

:1_error_no_internet
cls
echo ----------------------------------------------------------------------------------
echo.
echo There was an error while downloading RiiConnect24 Patcher.
echo There is no Internet connection!
pause>NUL
cmd
goto 1