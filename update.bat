@ECHO off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

ECHO =============================
ECHO Starting Wipe Day Script!!!
ECHO =============================

:start

if exist %ServerDirectory%wipetoken.json (
ECHO "wipetoken.json does not exist, continue with wipe sequence..."
goto :end
) else (

ECHO %batchName% Arguments: %1 %2 %3 %4 %5 %6 %7 %8 %9
set ServerDirectory=E:\RustServer\
set SteamCMD=E:\steamcmd\
ECHO "Downloading Latest version info"
cd "E:\Program Files (x86)\GnuWin32\bin"
wget --no-check-certificate https://umod.org/games/rust/latest.json -O "%ServerDirectory%latest.json"
cd "%ServerDirectory%"

if exist %ServerDirectory%installed.json (
ECHO.
ECHO =============================
ECHO CHECKING FOR UPDATE...
ECHO =============================
ECHO.

) else (
cd "%ServerDirectory%"
cmd /c > installed.json
ECHO "installed.json does not exist, created empty installed.json"

)
cd "%ServerDirectory%"
< installed.json (
  set /p InstalledOxideVersion=
)
< latest.json (
  set /p LatestOxideVersion=
)

if /i "!InstalledOxideVersion!" == "!LatestOxideVersion!" (
ECHO =============================
ECHO NO UPDATE REQUIRED!
ECHO =============================
TIMEOUT 60
goto :start 
) else (
ECHO =============================
ECHO STARTING UPDATE....
ECHO =============================

ECHO =============================
ECHO SHUTTING DOWN THE SERVER
ECHO =============================

NET STOP RustServ
TIMEOUT 10

"%SteamCMD%steamcmd.exe" +login anonymous +force_install_dir %ServerDirectory% +app_update 258550 validate +quit

cd "E:\Program Files (x86)\GnuWin32\bin"
wget --no-check-certificate https://umod.org/games/rust/download -O "%ServerDirectory%Oxide.Rust.zip"
wget --no-check-certificate https://umod.org/games/rust/latest.json -O "%ServerDirectory%installed.json"
cd "/d E:\Program Files\7-Zip\"
7z x -spe "%ServerDirectory%Oxide.Rust.zip" -o"%ServerDirectory%" -aoa
del "%ServerDirectory%Oxide.Rust.zip"
echo "Rust, Oxide and installed.json has been updated"
TIMEOUT 5



ECHO =============================
ECHO DELETING FILES
ECHO =============================

del "E:\RustServer\oxide\logs\*.txt"
del "E:\RustServer\oxide\logs\PlayerAdministration\*.txt"

ECHO =============================
ECHO LOG FILES DELETED
ECHO =============================

del "E:\RustServer\server\RustServer\*.sav*"
echo Save Files deleted!
del "E:\RustServer\server\RustServer\*.txt"
echo Deleted TXT files!
del "E:\RustServer\server\RustServer\*.db*"
echo Deleted DB files!
del "E:\RustServer\server\RustServer\*.map"
echo Deleted Map files!
del "E:\RustServer\server\RustServer\*.id"
echo Deleted ID files!
del "E:\RustServer\oxide\data\PlayerRanks.json"
echo Deleted PlayerRanks Database. Starting Fresh!
echo All files deleted!
echo Wipe Sequence Complete!
cd E:\RustServer\server\RustServer\cfg
CALL copystring
TIMEOUT 5

ECHO =============================
ECHO RESTARTING THE SERVER
ECHO =============================

NET START RustServ
TIMEOUT 5

)
)

:end
cd "%ServerDirectory%"
cmd /c > wipetoken.json
ECHO =============================
ECHO wipetoken.json created.
ECHO wipetoken.json already exists, wipe sequence aborted...
ECHO =============================
PAUSE
EXIT