# ============================================================
# Privacy-focused PowerShell profile for PS7 users
# ============================================================

# Stop update notifications
$env:POWERSHELL_UPDATECHECK = 'Off'

# Disable .NET diagnostics where possible
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'

# Disable PowerShell telemetry
$env:POWERSHELL_TELEMETRY_OPTOUT = '1'

# Prevent accidental module auto-loading surprises
$PSModuleAutoLoadingPreference = 'ModuleQualified'

# Disable command prediction
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -PredictionSource None
}

# Disable history file persistence
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -HistorySaveStyle SaveNothing
}

# Reduce history kept in memory
$MaximumHistoryCount = 100

# Avoid progress bars that can slow scripts
$ProgressPreference = 'SilentlyContinue'

# Don't prompt to install modules from PSGallery
$PSDefaultParameterValues['Install-Module:Force'] = $true

# Make PSGallery untrusted if available
try {
    $gallery = Get-PSRepository -Name PSGallery -ErrorAction Stop
    if ($gallery.InstallationPolicy -ne 'Untrusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
    }
}
catch {
}

# Conservative error handling
$ErrorActionPreference = 'Stop'

# Disable transcription by default if enabled elsewhere
try {
    Stop-Transcript | Out-Null
}
catch {
}

# Show versions at startup for auditing
Write-Verbose ("PowerShell {0}" -f $PSVersionTable.PSVersion)

# Explicitly identify FIPS state
try {
    $fips = [System.Security.Cryptography.CryptoConfig]::AllowOnlyFipsAlgorithms
    if ($fips) {
        Write-Host "FIPS mode detected"
    }
}
catch {
}

# Secure permissions reminder
# chmod 700 ~/.config/powershell
# chmod 600 ~/.config/powershell/profile.ps1

$PSModuleAutoLoadingPreference = 'None'
