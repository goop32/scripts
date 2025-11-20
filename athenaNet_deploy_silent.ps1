# athenaNet Device Manager silent installer
# v0.4, 2025/11/19, Sabrina Cazador/goop32

### TODO ###
# figure out how to scrape the latest version at the time the script is run, not have a statically set version (https://athenanet.athenahealth.com/1/1/admconfigurebrowser.esp, CurrentADM.msi)
# fix the part that checks if ADM is already installed - $instPath still exists but there is nothing in there. find a way to check if the folder has any contents, or better yet, find a way to reach the uninstall script

$TempDir = "ADMinstall"
$MsiUrl = "https://athenanet.athenahealth.com/static_20251106/shared/executables/athena/devices/athenadevicemanager/installers/3.1.4.0/athenaNetDeviceManager.msi?CSRFPROTECT=NONE"
$LogPath = New-TemporaryFile
$instPath = "C:\Program Files (x86)\athenahealth, Inc\aNetDeviceManager"

# welcome!
Write-Host "athenaNet Device Manager silent installer"
Write-Host "v0.4 released on 2025/11/19"
Write-Host "brought to you by https://github.com/goop32!"

# is it already installed?
# looks like, even after uninstalling, $instPath still exists. todo or whatever
#if (-Not (Test-Path -path $instPath)) {
#    Write-Host "INFO: No existing ADM installation found, continuing!"
#} else {
#    Write-Host "ERROR: ADM is already installed! Please uninstall from Settings > Apps > Installed Apps and run again. Exiting."
#    exit
#}

# create TempDir
New-Item -Path $env:Temp -Name $TempDir -ItemType "Directory"
if (Test-Path -path "$env:Temp\$TempDir") {
    Write-Host "INFO: TempDir exists, continuing..."
} else {
    Write-Host "ERROR: TempDir was not created! Exiting."
    exit
}

# set path for ADM download
$MsiPath = "$env:Temp\$TempDir\ADMinstaller.msi"

# download the MSI file
Invoke-WebRequest -Uri $MsiUrl -OutFile $MsiPath
Write-Host "INFO: Checking if ADM installer was downloaded..."
Write-Host "INFO: MsiPath is set to $MsiPath, just in case you were wondering."
if (Test-Path $MsiPath) {
    Write-Host "INFO: Installer is there! Continuing..."
} else {
    Write-Host "ERROR: Installer does not exist at this path! Exiting."
    exit
}

# use `msiexec` to silently install ADM
Write-Host "INFO: Initiating install! Our log is at $LogPath."
Start-Process msiexec -ArgumentList "/i $MsiPath /qn /L*v $LogPath" -NoNewWindow -Wait

# check if it installed
# I wonder if this is gonna run immediately after executing `msiexec`...
Write-Host "INFO: Checking if ADM has installed..."
if (Test-Path -path $instPath) {
    Write-Host "INFO: ADM installation found, yippee! See you later :)"
} else {
    Write-Host "ERROR: ADM was not installed. Chin up, queen - don't cry. The log path is above, give it another shot! Cleaning up and exiting."
}

# clean up after running the install & creating temp files
Write-Host "INFO: Cleaning up temporary files..."
Remove-Item -LiteralPath "$env:Temp\$TempDir" -Recurse
Write-Host "INFO: I think we're done here! Peace out \o/"
