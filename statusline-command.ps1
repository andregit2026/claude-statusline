param()

$inputJson = $input | Out-String
try {
    $data = $inputJson | ConvertFrom-Json
} catch {
    exit 0
}

$cwd     = if ($data.workspace.current_dir) { $data.workspace.current_dir } elseif ($data.cwd) { $data.cwd } else { "" }
$model   = if ($data.model.display_name)    { $data.model.display_name }    else { "" }

# Derive project folder (last path segment)
$folder  = if ($cwd) { Split-Path $cwd -Leaf } else { "" }

# Derive git branch (run in cwd, suppress errors)
$branch  = ""
if ($cwd -and (Test-Path $cwd)) {
    $branch = & git -C $cwd rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { $branch = "" }
}

$used      = $null
$remaining = $null
if ($null -ne $data.context_window.used_percentage) {
    $used      = [math]::Round($data.context_window.used_percentage)
    $remaining = [math]::Round($data.context_window.remaining_percentage)
}

$ctxInfo = if ($null -ne $used) { "context: ${used}% used / ${remaining}% left" } else { "context: --" }

# Context window size read dynamically from payload
$ctxWindowSize = $data.context_window.context_window_size
$ctxSize       = if ($ctxWindowSize) { "$([math]::Round($ctxWindowSize / 1000))k" } else { "" }
$modelDisplay  = if ($ctxSize) { "$model (${ctxSize})" } else { $model }

$ESC     = [char]27
$cyan    = "$ESC[96m"
$yellow  = "$ESC[93m"
$blue    = "$ESC[94m"
$green   = "$ESC[92m"
$magenta = "$ESC[95m"
$red     = "$ESC[91m"
$gray    = "$ESC[90m"
$reset   = "$ESC[0m"
$sep     = " ${gray}|${reset} "

$ctxColor = if ($null -eq $used)  { $yellow }
            elseif ($used -lt 50) { $green }
            elseif ($used -le 75) { $yellow }
            else                  { $red }

$locationPart = if ($branch) {
    "${blue}${folder}${reset}${gray} | ${reset}${magenta}${branch}${reset}"
} else {
    "${blue}${folder}${reset}"
}

Write-Host "${cyan}${modelDisplay}${reset}${sep}${ctxColor}${ctxInfo}${reset}${sep}${locationPart}"
