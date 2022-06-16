@echo off
echo                      i                    i:               
echo                   .QB.                     QB:             
echo                 iBBB                        BBQi           
echo               iBBBB.  Pr                rb   BBBQ:         
echo              QBQKBQ   QBBP            5BBB   5BPgBZ        
echo            rBBZKSBq   BQBBBP        PBBBQB   LBXqXBB:      
echo           UBZEq2PBB   JBEQBBRi:rii:QQBQZB2   BMPsP2DBr     
echo          1BZZP21EXB5   BgI.  .v:rL.  :qEB   PBXduuPSgQr    
echo         iBDbdIsIbU2Bb  .RY  .::77i:.  LQ.  QBIuZ5Y1PPQB.   
echo         BQddKLJIEujIBB:iEMSrqREvjEQJ7XMP rBB5s2PbsL5PZBB   
echo        uBDPPs7JXP1JUUQBBdKZQggMvjQZMQRSRBBQ5jUUdb27jIKgBr  
echo        BBEd2Lru5dujss1MQBgQEgggDgDDMgBBBBQqsjuSPEIr7USdBB  
echo        BMgPqPPPqdIjJ7vIMQBBq EMggRQ:2BBQRZjYv1SPPg5P5bdBB  
echo        BBQBB5YBBMbbKgPXdZQBBIuXdKJISBBQEMbggPUdZBBJjQBBQB  
echo        BQBJ    QQBBB5SBBZBBBBQPPSPgBBBBRBBuLMBBBB    rQBB. 
echo        BB.      BB1   .BBgu2BBBQBBBBUvEBB:   iBB:      BB  
echo        B.       Bv     S7    :BBBBr    .P     .B        B  
echo                                KB                          
                                                                                      
Echo.
Echo. 
Echo Welcome to the VRising Local to Dedicated Server Migration Tool
Echo. 
Echo Checking Permissions....

:CHECKPERMISSIONS
@echo off
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO Administrator PRIVILEGES Detected! 
    GOTO FIND_LOCALSAVES
) ELSE (
    ECHO .......
    ECHO .......
    ECHO NOT AN ADMIN! Please rerun the script as Administrator!
    ECHO .......
    ECHO .......
    pause
    exit
)

:FIND_LOCALSAVES
@echo off
echo.
echo.
set /p LOCALSAVES="Please enter the Local VRising Directory that contains your autosaves (Default in Appdata): "
echo ..
echo ..
set /p DEDICATEDSERVER="VRisingDedicatedServer folder path containing VRisingServer.exe: "
echo Saves Will be copied from: %LOCALSAVES%
echo.
echo to
echo.
echo %DATAPATH%
CHOICE /M "Are these Paths correct?"
IF %ERRORLEVEL% EQU 1 (
    GOTO CHOOSENAMES
) ELSE (
    echo Please reselect the correct folders
    GOTO FIND_LOCALSAVES
)

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
echo VRisingServer.exe -persistentDataPath .\save-data -serverName "%SERVERNAME%" -saveName "%SAVENAME%" -logFile ".\logs\VRisingServer.log"
)> %DEDICATEDSERVER%\Start_%SAVENAME%_Server.bat


:HOSTJSON
echo Backing up old ServerHostSettings.json file
move %DATAPATH%\ServerHostSettings.json ServerHostSettingsOLD.jsonbak
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
xcopy /c/y %DEDICATEDSERVER%\VRisingServer_Data\StreamingAssets\ServerGameSettings.json %DATAPATH%\ServerGameSettings.json

echo Saves Copied Over Successfully

:OPENFIREWALL
echo Opening UDP Firewall Ports on 9876 and 9877. You will need to manually configure port forwarding within your modem and any routers that are between (Modem -> Router -> Server Host)
netsh advfirewall firewall add rule name="VRising_9876" dir=in action=allow protocol=UDP localport=9876
netsh advfirewall firewall add rule name="VRising_9877" dir=in action=allow protocol=UDP localport=9877


:FINISH
@echo off
pause
