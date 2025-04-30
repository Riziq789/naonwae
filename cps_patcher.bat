@echo off
setlocal EnableDelayedExpansion

TITLE CreativePS Hosts Patcher
echo ======== CREATIVEPS.EU HOSTS PATCHER ========
echo.
echo INFO: Disable your Anti Virus if it blocks the hosts file from being changed.
echo.
echo.

:: Ensure admin privileges (we require them for updating the host entries)
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if %errorlevel% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "TEMP_FILE=%TEMP%\hosts_tmp.txt"

:: ==== MAIN LOGIC STARTS HERE ====

set "IP1=51.75.87.53"
set "IP2=15.235.28.24"

echo.
set /p DO_INSTALL=Do you want to install CreativePS hosts entries? (Y/N): 
if /I "%DO_INSTALL%"=="Y" (
    call :remove_growtopia

    echo.
    if not defined IP1 (
        echo Failed to resolve creativeps.eu - Visit us on discord.gg/cps or creativeps.eu!
        start https://discord.gg/cps
        timeout /t 5 /nobreak >nul
        exit /b
    )
    if not defined IP2 (
        echo Failed to resolve alt.creativeps.eu - Visit us on discord.gg/cps or creativeps.eu!
        start https://discord.gg/cps
        timeout /t 5 /nobreak >nul
        exit /b
    )

    set lines[0]=%IP1% www.growtopia1.com
    set lines[1]=%IP2% www.growtopia2.com
    set lines[2]=%IP1% growtopia1.com
    set lines[3]=%IP2% growtopia2.com
    set lines[4]=%IP1% growtopiagame.com
    set lines[5]=%IP1% login.growtopiagame.com
    set lines[6]=%IP1% rtsoft.com
    set lines[7]=%IP2% hamumu.com

    echo.
    echo Adding new entries...
    for /L %%i in (0,1,7) do (
        findstr /C:"!lines[%%i]!" "%HOSTS_FILE%" >nul || (
            echo !lines[%%i]!>> "%HOSTS_FILE%"
            echo Added: !lines[%%i]!
        )
    )

    echo.
    echo Flushing DNS cache...
    ipconfig /flushdns
    echo.
    echo Install complete. Close Growtopia and open it again, and you can start playing.
    start https://discord.gg/cps
    pause
    exit /b
)

:: If not installing, ask to uninstall
set /p DO_UNINSTALL=Do you want to uninstall Growtopia hosts entries? (Y/N): 
if /I "%DO_UNINSTALL%"=="Y" (
    call :remove_growtopia
    echo.
    echo Flushing DNS cache...
    ipconfig /flushdns
    echo.
    echo Uninstall complete.
    pause
    exit /b
)

echo.
echo No changes made.
pause
exit /b

:: ==== FUNCTION DEFINITION AT THE BOTTOM ====
:remove_growtopia
echo Clearing Host entries...
break > "%TEMP_FILE%"
for /f "usebackq delims=" %%A in ("%HOSTS_FILE%") do (
    echo %%A | findstr /I "growtopia" >nul
    if errorlevel 1 (
        echo %%A | findstr /I "rtsoft" >nul
        if errorlevel 1 (
            echo %%A | findstr /I "hamumu" >nul
            if errorlevel 1 (
                echo %%A>> "%TEMP_FILE%"
            )
        )
    )
)

copy /Y "%TEMP_FILE%" "%HOSTS_FILE%" >nul
del "%TEMP_FILE%"
echo Done!
goto :eof