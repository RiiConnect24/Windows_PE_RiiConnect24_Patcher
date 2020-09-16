@echo off

cd /d "%~dp0"
echo 	Starting up...
echo	The program is starting...
:: ===========================================================================
:: Windows PE builder for RiiConnect24 Patcher
set version=1.0.0
:: AUTHORS: KcrPL
:: ***************************************************************************
:: Copyright (c) 2020 KcrPL, RiiConnect24 and it's (Lead) Developers
:: ===========================================================================

:script_start
echo 	.. Setting up the variables
:: Window size (Lines, columns)
set s=NUL

set original_cd=%cd%
cd /d "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"

:: Window Title
title Windows PE Builder for RiiConnect24 Patcher v%version% Created by @KcrPL
set last_build=2020/09/16
set at=00:30
set header=Windows PE Builder for RiiConnect24 Patcher v%version% Created by @KcrPL (Compiled on %last_build% at %at%)

net session>NUL
if not %errorlevel%==0 goto need_elevated_perms


goto 1
:need_elevated_perms
cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
echo There was an error!
echo.
echo You need to run this program as an administrator.
pause>NUL
exit
:1
cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
echo Welcome! This tool will help you create the .ISO image for Windows PE 10 version for
echo the RiiConnect24 Patcher.
echo.
echo It will help set all the files up and build the image.
echo.
echo Some info:
echo Original .bat dir: %original_cd%
echo Tools: %cd%
echo.
echo 1. Continue
echo 2. Exit
set /p s=Choose: 
if %s%==1 goto 1_2
if %s%==2 exit

:1_2
cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
echo Info.
echo.
echo Put:
echo - curl.exe
echo - winpe.jpg
echo - startnet.cmd
echo - subinacl.exe
echo    in source_files/ and proceed. Otherwise, you won't be able to continue.
echo.
pause

if not exist "%original_cd%\source_files\curl.exe" goto 1_2
if not exist "%original_cd%\source_files\startnet.cmd" goto 1_2
if not exist "%original_cd%\source_files\subinacl.exe" goto 1_2
if not exist "%original_cd%\source_files\winpe.jpg" goto 1_2

goto 1_3

:1_3
cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
rmdir /s /q "%original_cd%\WinPE_x86"
title 12,5%%
:: Copy working files
call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
call copype.cmd x86 "%original_cd%\WinPE_x86"

title 25%%
:: Mount image
Dism /Mount-Image /ImageFile:%original_cd%\WinPE_x86\media\sources\boot.wim /index:1 /MountDir:"%original_cd%\WinPE_x86\mount"

title 37,5%%
:: Copy new startup script_start
del /q "%original_cd%\WinPE_x86\mount\Windows\System32\StartNet.cmd"
copy "%original_cd%\source_files\StartNet.cmd" "%original_cd%\WinPE_x86\mount\Windows\System32\"

title 50%%
:: Take ownership
"%original_cd%/source_files/subinacl.exe" /file "%original_cd%\WinPE_x86\mount\Windows\System32\winpe.jpg" /setowner=%USERDOMAIN%\%USERNAME% "
"%original_cd%/source_files/subinacl.exe" /file "%original_cd%\WinPE_x86\mount\Windows\System32\winpe.jpg" /grant=%USERDOMAIN%\%USERNAME%=F

title 62,5%%
:: Replace background
del "%original_cd%\WinPE_x86\mount\Windows\System32\winpe.jpg" 
copy "%original_cd%\source_files\winpe.jpg" "%original_cd%\WinPE_x86\mount\Windows\System32\"


title 75%%
:: Copy curl
md "%original_cd%\WinPE_x86\mount\RiiConnect24"
copy "%original_cd%\source_files\curl.exe" "%original_cd%\WinPE_x86\mount\RiiConnect24"

:: Add .NET Framework
Dism /Image:"%original_cd%\WinPE_x86\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs\WinPE-WMI.cab"
Dism /Image:"%original_cd%\WinPE_x86\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs\WinPE-NetFX.cab"


title 87,5%%
:: Unmount
Dism /Unmount-Image /MountDir:"%original_cd%\WinPE_x86\mount" /commit

title 99,9%%
:: Create bootable
call MakeWinPEMedia.cmd /ISO "%original_cd%\WinPE_x86" "%original_cd%\RiiConnect24 Patcher Windows PE.iso"

title 100%%
goto 2
:2
pause
cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
echo All done, all done!
echo.
echo Press any key to exit.

pause>NUL
exit






