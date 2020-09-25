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

set /a x86_build=1
set /a amd64_build=1
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
echo   You will need a Windows 10 ADK installed.
echo   https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

echo.
echo  Some info:
echo  Original .bat dir: %original_cd%
echo  Tools: %cd%
echo.
echo Build:
if %x86_build%==1 echo 1. [X] x86 (32 bit)
if %x86_build%==0 echo 1. [ ] x86 (32 bit)
if %amd64_build%==1 echo 2. [X] AMD64 (64 bit)
if %amd64_build%==0 echo 2. [ ] AMD64 (64 bit)

echo.
echo 3. Continue
echo 4. Exit
set /p s=Choose: 
if %s%==1 goto change_86
if %s%==2 goto change_amd64
if %s%==3 goto 1_2
if %s%==4 exit
goto 1
:change_86
if %x86_build%==1 set /a x86_build=0&goto 1
if %x86_build%==0 set /a x86_build=1&goto 1

:change_amd64
if %amd64_build%==1 set /a amd64_build=0&goto 1
if %amd64_build%==0 set /a amd64_build=1&goto 1


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
echo - PENetworkManager/
echo - Total Commander

echo    in source_files/ and proceed. Otherwise, you won't be able to continue.
echo.
pause

if not exist "%original_cd%\source_files\curl_x86.exe" goto 1_2
if not exist "%original_cd%\source_files\curl_x64.exe" goto 1_2
if not exist "%original_cd%\source_files\startnet.cmd" goto 1_2
if not exist "%original_cd%\source_files\subinacl.exe" goto 1_2
if not exist "%original_cd%\source_files\winpe_x86.jpg" goto 1_2
if not exist "%original_cd%\source_files\winpe_x64.jpg" goto 1_2

goto 1_3_x86

:1_3_x86
if %x86_build%==0 goto 1_3_x64
:: building x86 image

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
copy "%original_cd%\source_files\winpe_x86.jpg" "%original_cd%\WinPE_x86\mount\Windows\System32\winpe.jpg"


title 75%%
:: Copy curl
md "%original_cd%\WinPE_x86\mount\RiiConnect24"
copy "%original_cd%\source_files\curl_x86.exe" "%original_cd%\WinPE_x86\mount\RiiConnect24\curl.exe"

:: Copy timeout
copy "%original_cd%\source_files\timeout_x86.exe" "%original_cd%\WinPE_x86\mount\Windows\system32\timeout.exe"


:: Add .NET Framework
Dism /Image:"%original_cd%\WinPE_x86\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs\WinPE-WMI.cab"
Dism /Image:"%original_cd%\WinPE_x86\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs\WinPE-NetFX.cab"

:: Copy PE Network Manager
if not exist "%original_cd%\WinPE_x86\mount\PENetworkManager" md "%original_cd%\WinPE_x86\mount\PENetworkManager"
copy "%original_cd%\source_files\PENetworkManager_x86\*.*" "%original_cd%\WinPE_x86\mount\PENetworkManager"


:: Copy File Manager
copy "%original_cd%\source_files\TOTALCMD_x86.exe" "%original_cd%\WinPE_x86\mount\TOTALCMD.exe"


:: Set scratch space
Dism /Set-ScratchSpace:256 /Image:"%original_cd%\WinPE_x86\mount"



title 87,5%%
:: Unmount
Dism /Unmount-Image /MountDir:"%original_cd%\WinPE_x86\mount" /commit

title 99,9%%
:: Create bootable
echo.
call MakeWinPEMedia.cmd /ISO "%original_cd%\WinPE_x86" "%original_cd%\RiiConnect24 Patcher Windows PE_x86.iso"

title 100%%
goto 1_3_x64

:1_3_x64
if %amd64_build%==0 goto 2
:: building x86 image

cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
rmdir /s /q "%original_cd%\WinPE_AMD64"
title 12,5%%
:: Copy working files
call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
call copype.cmd AMD64 "%original_cd%\WinPE_AMD64"

title 25%%
:: Mount image
Dism /Mount-Image /ImageFile:%original_cd%\WinPE_AMD64\media\sources\boot.wim /index:1 /MountDir:"%original_cd%\WinPE_AMD64\mount"

title 37,5%%
:: Copy new startup script_start
del /q "%original_cd%\WinPE_AMD64\mount\Windows\System32\StartNet.cmd"
copy "%original_cd%\source_files\StartNet.cmd" "%original_cd%\WinPE_AMD64\mount\Windows\System32\"

title 50%%
:: Take ownership
"%original_cd%/source_files/subinacl.exe" /file "%original_cd%\WinPE_AMD64\mount\Windows\System32\winpe.jpg" /setowner=%USERDOMAIN%\%USERNAME% "
"%original_cd%/source_files/subinacl.exe" /file "%original_cd%\WinPE_AMD64\mount\Windows\System32\winpe.jpg" /grant=%USERDOMAIN%\%USERNAME%=F

title 62,5%%
:: Replace background
del "%original_cd%\WinPE_AMD64\mount\Windows\System32\winpe.jpg" 
copy "%original_cd%\source_files\winpe_x64.jpg" "%original_cd%\WinPE_AMD64\mount\Windows\System32\winpe.jpg"


title 75%%
:: Copy curl
md "%original_cd%\WinPE_AMD64\mount\RiiConnect24"
copy "%original_cd%\source_files\curl_x64.exe" "%original_cd%\WinPE_AMD64\mount\RiiConnect24\curl.exe"

:: Copy timeout
copy "%original_cd%\source_files\timeout_x64.exe" "%original_cd%\WinPE_AMD64\mount\Windows\system32\timeout.exe"


:: Add .NET Framework
Dism /Image:"%original_cd%\WinPE_AMD64\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /Image:"%original_cd%\WinPE_AMD64\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"

:: Copy PE Network Manager
if not exist "%original_cd%\WinPE_AMD64\mount\PENetworkManager" md "%original_cd%\WinPE_AMD64\mount\PENetworkManager"
copy "%original_cd%\source_files\PENetworkManager_x64\*.*" "%original_cd%\WinPE_AMD64\mount\PENetworkManager"


:: Copy File Manager
copy "%original_cd%\source_files\TOTALCMD_x64.exe" "%original_cd%\WinPE_AMD64\mount\TOTALCMD.exe"

:: Set scratch space
Dism /Set-ScratchSpace:256 /Image:"%original_cd%\WinPE_amd64\mount"



title 87,5%%
:: Unmount
Dism /Unmount-Image /MountDir:"%original_cd%\WinPE_AMD64\mount" /commit

title 99,9%%
:: Create bootable
echo.
call MakeWinPEMedia.cmd /ISO "%original_cd%\WinPE_AMD64" "%original_cd%\RiiConnect24 Patcher Windows PE_AMD64.iso"

title 100%%
pause
:2
cls
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
echo All done, all done!
echo.
echo Press any key to exit.

pause>NUL
exit






