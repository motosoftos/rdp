@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "NGROK_URL=%~1"
set "RDP_USER=%~2"
set "RDP_PASS=%~3"

if not defined RDP_USER set "RDP_USER=rdpuser"
if not defined RDP_PASS (
    echo ERROR: RDP password was not provided.
    exit /b 2
)

REM Create the account, or reset its password if it exists.
net user "%RDP_USER%" >nul 2>&1
if errorlevel 1 (
    net user "%RDP_USER%" "%RDP_PASS%" /add
) else (
    net user "%RDP_USER%" "%RDP_PASS%"
)

if errorlevel 1 (
    echo ERROR: Failed to create or configure RDP user.
    exit /b 1
)

REM Add the account to the local Administrators group.
net localgroup Administrators "%RDP_USER%" /add >nul 2>&1

REM Verify membership even if the account was already a member.
net localgroup Administrators | findstr /i /c:"%RDP_USER%" >nul
if errorlevel 1 (
    echo ERROR: RDP user is not in the Administrators group.
    exit /b 1
)

echo RDP account configured successfully.
echo Ngrok endpoint: "%NGROK_URL%"
echo Username: "%RDP_USER%"
exit /b 0
