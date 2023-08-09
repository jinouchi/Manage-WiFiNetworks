param (
    [Parameter()]
    [switch]$Backup,
    [switch]$Wipe,
    [switch]$Restore,
    [switch]$Cleanup
)

# Set variables
$BackupDirName = "Wi-Fi Passwords"
$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$BackupPath = "$DesktopPath\$BackupDirName"

# Define Functions
function Backup {
    Write-Output "Backing up all saved Wi-Fi networks..."

    # Create the backup folder
    New-Item -Path $DesktopPath -Name "$BackupDirName" -ItemType "directory" -ErrorAction SilentlyContinue

    # Backup Wi-Fi Passwords 
    netsh wlan export profile key=clear folder="$BackupPath"
    Write-Output "Done: $((Get-ChildItem "$DesktopPath\$BackupDirName" | Measure-Object).Count) Wi-Fi networks have been saved to $BackupPath\"
}

function Wipe {
    Write-Output "Forgetting all Wi-Fi networks..."
    netsh wlan delete profile name=* i=*
    Write-Output "Done."
}

function Restore {
    Write-Output "Restoring Wi-Fi networks from backup..."
    $Files = Get-ChildItem $BackupPath
    foreach ($File in $Files){
        netsh wlan add profile filename="$BackupPath\$File" user=current
    }
    Write-Output "Done: $((Get-ChildItem "$DesktopPath\$BackupDirName" | Measure-Object).Count) Wi-Fi networks have been restored."
}

function Cleanup {
	Remove-Item -Recurse $BackupPath
}

# Begin Logic
if ($Backup) {
    Backup
}

if ($Wipe) {
    Wipe
}

if ($Restore) {
    Restore
}

if ($Cleanup) {
    Cleanup
}
