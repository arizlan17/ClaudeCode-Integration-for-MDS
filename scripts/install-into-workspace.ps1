# Install this proof of concept's Claude settings into another Helix client root.
# The destination can be any drive. .p4config and helix-lines.local are written
# only in that folder and are not copied from this proof of concept.
param(
    [Parameter(Mandatory = $true)][string]$Destination,
    [Parameter(Mandatory = $true)][string]$P4Port,
    [Parameter(Mandatory = $true)][string]$P4User,
    [Parameter(Mandatory = $true)][string]$P4Client,
    [Parameter(Mandatory = $true)][string]$MainPath,
    [Parameter(Mandatory = $true)][string]$DevPath,
    [Parameter(Mandatory = $true)][string]$FeaturesPath
)

$ErrorActionPreference = "Stop"
$source = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

$copyFiles = @(
    "CLAUDE.md",
    ".mcp.json",
    ".p4ignore"
)
foreach ($name in $copyFiles) {
    Copy-Item -Force (Join-Path $source $name) (Join-Path $Destination $name)
}

Copy-Item -Recurse -Force (Join-Path $source ".claude") (Join-Path $Destination ".claude")
Remove-Item -Force (Join-Path $Destination ".claude\helix-lines.local") -ErrorAction SilentlyContinue
Remove-Item -Force (Join-Path $Destination ".claude\settings.local.json") -ErrorAction SilentlyContinue

$scriptDest = Join-Path $Destination "scripts"
New-Item -ItemType Directory -Force -Path $scriptDest | Out-Null
foreach ($name in @("start-p4mcp.cmd", "start_p4mcp.py", "check-enterprise.ps1")) {
    Copy-Item -Force (Join-Path $source "scripts\$name") (Join-Path $scriptDest $name)
}

@"
P4PORT=$P4Port
P4USER=$P4User
P4CLIENT=$P4Client
P4IGNORE=.p4ignore
"@ | Set-Content -Encoding ascii (Join-Path $Destination ".p4config")

@"
MAIN=$MainPath
DEV=$DevPath
FEATURES=$FeaturesPath
"@ | Set-Content -Encoding ascii (Join-Path $Destination ".claude\helix-lines.local")

Write-Host "Installed Claude settings into $Destination"
Write-Host "Next, in that folder: p4 trust; p4 login; powershell -File scripts\check-enterprise.ps1"
