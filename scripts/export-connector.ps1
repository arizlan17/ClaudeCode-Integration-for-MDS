# Build a zip other developers can install into their own Helix client.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$stage = Join-Path $root "export\claude-helix-connector"
$zip = Join-Path $root "export\claude-helix-connector.zip"

if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

Copy-Item (Join-Path $root "share\HOW-TO-INSTALL.md") (Join-Path $stage "HOW-TO-INSTALL.md")
Copy-Item (Join-Path $root "Install Claude Helix.cmd") (Join-Path $stage "Install Claude Helix.cmd")
foreach ($name in @("CLAUDE.md", ".mcp.json", ".p4ignore", ".p4config.template")) {
    Copy-Item (Join-Path $root $name) (Join-Path $stage $name)
}
New-Item -ItemType Directory -Force -Path (Join-Path $stage "config") | Out-Null
Copy-Item (Join-Path $root "config\helix-lines.template") (Join-Path $stage "config\helix-lines.template")

Copy-Item -Recurse (Join-Path $root ".claude") (Join-Path $stage ".claude")
Remove-Item -Force (Join-Path $stage ".claude\helix-lines.local") -ErrorAction SilentlyContinue
Remove-Item -Force (Join-Path $stage ".claude\settings.local.json") -ErrorAction SilentlyContinue

$scripts = Join-Path $stage "scripts"
New-Item -ItemType Directory -Force -Path $scripts | Out-Null
foreach ($name in @("start-p4mcp.cmd", "start_p4mcp.py", "check-enterprise.ps1", "install-into-workspace.ps1", "install-ui.ps1")) {
    Copy-Item (Join-Path $root "scripts\$name") (Join-Path $scripts $name)
}

if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $zip -Force
Write-Host "ZIP $zip"
Get-ChildItem $stage -Recurse -File | ForEach-Object { $_.FullName.Substring($stage.Length + 1) }
