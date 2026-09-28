# Check the local Helix connection and the P4 MCP package.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "=== p4 info ==="
p4 info
Write-Host "=== login ==="
p4 login -s
Write-Host "=== client ==="
p4 client -o p4_imp_poc | Select-String -Pattern "^(Client|Owner|Host|Root|View):|^	//"
Write-Host "=== recent poc changes ==="
p4 changes -m 5 //depot/poc/...
Write-Host "=== mcp package ==="
& "$env:USERPROFILE\.local\bin\uvx.exe" p4mcp-server --version
