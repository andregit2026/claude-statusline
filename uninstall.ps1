# Claude Code Status Line - Uninstaller
# Removes the statusLine entry from settings.json and deletes the script

$ErrorActionPreference = "Stop"

$claudeDir    = Join-Path $env:USERPROFILE ".claude"
$settingsFile = Join-Path $claudeDir "settings.json"
$scriptDest   = Join-Path $claudeDir "statusline-command.ps1"

# 1 - Remove script file
if (Test-Path $scriptDest) {
    Remove-Item $scriptDest -Force
    Write-Host "Removed $scriptDest"
} else {
    Write-Host "Script not found, skipping: $scriptDest"
}

# 2 - Remove statusLine key from settings.json
if (Test-Path $settingsFile) {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
    if ($settings.PSObject.Properties["statusLine"]) {
        $settings.PSObject.Properties.Remove("statusLine")
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
        Write-Host "Removed statusLine from $settingsFile"
    } else {
        Write-Host "No statusLine entry found in settings.json, nothing to remove."
    }
} else {
    Write-Host "settings.json not found, nothing to remove."
}

Write-Host ""
Write-Host "Done. Restart Claude Code to apply."
