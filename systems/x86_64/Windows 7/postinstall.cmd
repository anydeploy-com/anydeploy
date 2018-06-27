Taskkill /IM MicrosoftEdge.exe /F
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"
powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
choco install googlechrome adobereader flashplayerplugin flashplayeractivex jre8 sdio -y --force --ignore-checksums
powershell -Command "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force"
powershell -Command "Install-Module -Name PSWindowsUpdate -Force"

@copy /y NUL drivers\DP_LAN_Intel_17062.7z
@copy /y NUL drivers\DP_LAN_Others_17075.7z
@copy /y NUL drivers\DP_LAN_Realtek-NT_17075.7z
@copy /y NUL drivers\DP_LAN_Realtek-XP_17023.7z
:: Create update app script
@copy /y NUL scripts\anydeploy-update-app.txt
@echo activetorrent 1 > scripts\anydeploy-update-app.txt
@echo checkupdates >> scripts\anydeploy-update-app.txt
@echo get indexes >> scripts\anydeploy-update-app.txt
@echo end >> scripts\anydeploy-update-app.txt
:: Create update indexes script
@copy /y NUL scripts\anydeploy-update-indexes.txt
@echo activetorrent 1 > scripts\anydeploy-update-app.txt
@echo checkupdates >> scripts\anydeploy-update-app.txt
@echo get indexes >> scripts\anydeploy-update-app.txt
@echo end >> scripts\anydeploy-update-app.txt
:: Create update drivers script
@copy /y NUL scripts\anydeploy-update-drivers.txt
@echo init > scripts\anydeploy-update-drivers.txt
@echo activetorrent 2 >> scripts\anydeploy-update-drivers.txt
@echo checkupdates >> scripts\anydeploy-update-drivers.txt
@echo get driverpacks updates >> scripts\anydeploy-update-drivers.txt
@echo end >> scripts\anydeploy-update-drivers.txt
:: Execute Scripts
@echo ==============================
@echo Snappy Driver Installer Origin
@echo       updating app
@echo ==============================
@SDIO_x64_R667.exe -script:scripts\anydeploy-update-app.txt
@echo ==============================
@echo Snappy Driver Installer Origin
@echo       updating indexes
@echo ==============================
@SDIO_x64_R667.exe -script:scripts\anydeploy-update-indexes.txt
@echo ==============================
@echo Snappy Driver Installer Origin
@echo       updating drivers
@echo ==============================
@SDIO_x64_R667.exe -script:scripts\anydeploy-update-drivers.txt
sleep 10
