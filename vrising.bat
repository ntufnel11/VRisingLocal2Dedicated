:FIND_LOCALSAVES
@echo off
CHOICE /N
set /p LOCALSAVES="Local Saves Directory: "
echo The directory %LOCALSAVES% contains your autosaves, is this correct?
echo ..
echo ..
CHOICE /M "Press Y if you see your autosaves in this location"
set /p DEDICATEDSERVER="VRisingDedicatedServer folder path: "
echo The directory %DEDICATEDSERVER% contains The VRisingServer.exe program, is this correct?
CHOICE /M "Press Y for Yes if you can see the VRisingServer.exe program in this location"

echo ..............
echo ..............

:CHOOSENAMES
echo What should I call your server?
set /p SERVERNAME= "Server Name Set to: " 
echo What should I call your save name? Please use a single word with no special characters
set /p SAVENAME="Save Name set to: " 
set DATAPATH=%DEDICATEDSERVER%\save-data\Saves\v1\%SAVENAME%
echo Data Path is %DATAPATH%


:COPY_SAVES
echo copying local saves
@echo off
xcopy /s/i/c "%LOCALSAVES%\" "%DATAPATH%\" 
echo Saves Copied Successfully


:MAKESTARTSCRIPT
echo Creating Start Script
(
echo @echo off
echo REM Copy this script to your own file and modify to your content. This file can be overwritten when updating.
echo set SteamAppId=1604030
echo echo "Starting V Rising Dedicated Server - PRESS CTRL-C to exit"
echo.
echo @echo on
echo VRisingServer.exe -persistentDataPath .\save-data -serverName "%SERVERNAME" -saveName "%SAVENAME" -logFile ".\logs\VRisingServer.log"
)> %DEDICATEDSERVER%\Start_%SAVENAME%_Server.bat


:HOSTJSON
echo Backing up old ServerHostSettings.json file
mv %DATAPATH%\ServerHostSettings.json ServerHostSettingsOLD.jsonbak
echo Creating Dedicated Host json file
(
echo {
echo  "Name": "%SERVERNAME",
echo  "Description": "Dedicated %SERVERNAME% Server",
echo  "Port": 9876,
echo  "QueryPort": 9877,
echo  "MaxConnectedUsers": 40,
echo  "MaxConnectedAdmins": 4,
echo  "ServerFps": 30,
echo  "SaveName": "%SERVERNAME%",
echo  "Password": "",
echo  "Secure": true,
echo  "ListOnMasterServer": true,
echo  "AutoSaveCount": 50,
echo  "AutoSaveInterval": 1200,
echo  "GameSettingsPreset": "",
echo  "AdminOnlyDebugEvents": true,
echo  "DisableDebugEvents": false
echo  "Rcon": {
echo    "Enabled": false,
echo    "Port": 25575,
echo    "Password": ""
echo  }
echo }
)> %DATAPATH%\ServerHostSettings.json

:COPYGAMESETTINGS
xcopy %DEDICATEDSERVER%
echo copying ServerGameSettings.json file
xcopy /c/y %DEDICATEDSERVER%\VRisingServer_Data\StreamingAssets\SettingsServerGameSettings.json %DATAPATH%\ServerGameSettings.json

echo Saves Copied Over Successfully

:OPENFIREWALL
echo Opening UDP Firewall Ports on 9876 and 9877. You will need to manually configure port forwarding within your modem and any routers that are between (Modem -> Router -> Server Host)
netsh advfirewall firewall add rule name="VRising_9876" dir=in action=allow protocol=UDP localport=9876
netsh advfirewall firewall add rule name="VRising_9877" dir=in action=allow protocol=UDP localport=9877


:FINISH
@echo off
pause
