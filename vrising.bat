:FIND_LOCALSAVES
@echo off
set /p LOCALSAVES="Local Saves Directory: "
echo The directory %LOCALSAVES% contains your autosaves, is this correct?
CHOICE /C YNC /M "Press Y for Yes, N for No or C for Cancel."
set /p DEDICATEDSERVER="VRisingDedicatedServer folder path: "
echo The directory %DEDICATEDSERVER% contains The VRisingServer.exe program, is this correct?
CHOICE /C YNC /M "Press Y for Yes, N for No or C for Cancel."
set DATAPATH=%DEDICATEDSERVER%\save-data\Saves\v1\Mindgames
echo Data Path is %DATAPATH%


:COPY_SAVES
echo copying local saves
echo on
xcopy /s/i/c "%LOCALSAVES%\" "%DATAPATH%\" 

:MAKESTARTSCRIPT
echo copying start script
(
echo @echo off
echo REM Copy this script to your own file and modify to your content. This file can be overwritten when updating.
echo set SteamAppId=1604030
echo echo "Starting V Rising Dedicated Server - PRESS CTRL-C to exit"
echo.
echo @echo on
echo VRisingServer.exe -persistentDataPath .\save-data -serverName "Mindgames' Server" -saveName "Mindgames" -logFile ".\logs\VRisingServer.log"
)> %DEDICATEDSERVER%\Start_Mindgames_Server.bat


:HOSTJSON
echo copying host json file
(
echo {
echo  "Name": "Mindgames' Server",
echo  "Description": "Dedicated Mindgames' Server",
echo  "Port": 9876,
echo  "QueryPort": 9877,
echo  "MaxConnectedUsers": 40,
echo  "MaxConnectedAdmins": 4,
echo  "ServerFps": 30,
echo  "SaveName": "Mindgames",
echo  "Password": "farts",
echo  "Secure": true,
echo  "ListOnMasterServer": true,
echo  "AutoSaveCount": 50,
echo  "AutoSaveInterval": 1200,
echo  "GameSettingsPreset": "",
echo  "AdminOnlyDebugEvents": true,
echo  "DisableDebugEvents": false
echo }
)> %DATAPATH%\ServerHostSettings.json

:COPYGAMESETTINGS
echo copying ServerGameSettings.json file
xcopy /c ServerGameSettings.json %DATAPATH%\ServerGameSettings.json

pause
