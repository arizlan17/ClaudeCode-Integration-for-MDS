# Checks the Helix connection this workspace will hand to Claude.
# Run from anywhere. The script moves to the workspace root.

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

function Show-Check($name, $ok, $detail) {
    $mark = if ($ok) { "OK" } else { "FAIL" }
    Write-Host "$mark  $name  $detail"
}

Write-Host "Workspace: $(Get-Location)"
Write-Host ""

if (-not (Test-Path .\.p4config)) {
    Show-Check ".p4config" $false "copy .p4config.template to .p4config"
    exit 1
}

$cfg = @{}
Get-Content .\.p4config | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
        $parts = $line.Split("=", 2)
        $cfg[$parts[0].Trim()] = $parts[1].Trim()
    }
}

if ($cfg.ContainsKey("P4PASSWD")) {
    Show-Check "password" $false "remove P4PASSWD from .p4config and use p4 login"
} else {
    Show-Check "password" $true "ticket login, no password in .p4config"
}

$info = p4 info 2>&1 | Out-String
$loggedIn = $LASTEXITCODE -eq 0
Show-Check "p4 info" $loggedIn (($info -split "`n" | Select-Object -First 4) -join " | ")

$login = p4 login -s 2>&1 | Out-String
Show-Check "ticket" ($LASTEXITCODE -eq 0) $login.Trim()

$userType = ""
if ($cfg["P4USER"]) {
    $userType = (p4 -ztag -F "%Type%" user -o $cfg["P4USER"] 2>&1 | Out-String).Trim()
}
$standard = ($userType -eq "" -or $userType -eq "standard")
Show-Check "user type" $standard $(if ($userType) { $userType } else { "standard (default)" })

if ($cfg["P4PORT"] -like "ssl:*") {
    $trust = p4 trust -l 2>&1 | Out-String
    Show-Check "ssl trust" ($trust -match "\*\*\*") $trust.Trim()
} else {
    Show-Check "ssl trust" $true "P4PORT is not ssl; run p4 trust after switching to an ssl server"
}

$client = p4 client -o $cfg["P4CLIENT"] 2>&1 | Out-String
$hostLine = ($client -split "`n" | Where-Object { $_ -match "^Host:" } | Select-Object -First 1)
$thisHost = $env:COMPUTERNAME
if ($hostLine -match "^Host:\s*$") {
    Show-Check "client host" $true "Host is empty, so any machine can use $($cfg['P4CLIENT'])"
} elseif ($hostLine -match [regex]::Escape($thisHost)) {
    Show-Check "client host" $true "$hostLine"
} else {
    Show-Check "client host" $false "this PC is $thisHost; client says $hostLine"
}

Write-Host ""
Write-Host "P4PORT=$($cfg['P4PORT'])"
Write-Host "P4USER=$($cfg['P4USER'])"
Write-Host "P4CLIENT=$($cfg['P4CLIENT'])"
Write-Host "Enterprise server: set P4PORT=ssl:helix.example.com:1666 in .p4config, then p4 trust and p4 login."
