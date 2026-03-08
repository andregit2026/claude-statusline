# Claude Code Status Line - Installer
# Copies statusline-command.ps1 to ~/.claude/ and registers it in settings.json

$ErrorActionPreference = "Stop"

$claudeDir   = Join-Path $env:USERPROFILE ".claude"
$settingsFile = Join-Path $claudeDir "settings.json"
$scriptDest  = Join-Path $claudeDir "statusline-command.ps1"
$scriptSrc   = Join-Path $PSScriptRoot "statusline-command.ps1"

# 1 - Ensure ~/.claude exists
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
    Write-Host "Created $claudeDir"
}

# 2 - Copy the script
Copy-Item -Path $scriptSrc -Destination $scriptDest -Force
Write-Host "Copied statusline-command.ps1 -> $scriptDest"

# 3 - Read or initialise settings.json
$settings = if (Test-Path $settingsFile) {
    Get-Content $settingsFile -Raw | ConvertFrom-Json
} else {
    [pscustomobject]@{}
}

# 4 - Inject / overwrite the statusLine block
$statusLine = [pscustomobject]@{
    type    = "command"
    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptDest`""
}

# Add-Member handles both new and existing property
if ($settings.PSObject.Properties["statusLine"]) {
    $settings.statusLine = $statusLine
} else {
    $settings | Add-Member -MemberType NoteProperty -Name "statusLine" -Value $statusLine
}

# 5 - Write back
$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
Write-Host "Updated $settingsFile"
Write-Host ""
Write-Host "Done. Restart Claude Code to activate the status line."
