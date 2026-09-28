# Recreate the p4_imp_poc client that maps //depot/poc/... onto this folder.
# Safe to re-run. Does not delete the depot or other clients.

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$root = (Get-Location).Path
$spec = @"
Client: p4_imp_poc

Owner: arizlan

Host: SL-ARizlan2

Description:
	Claude Code and P4 Helix proof of concept.

Root: $root

Options: noallwrite noclobber nocompress unlocked nomodtime normdir noaltsync

SubmitOptions: revertunchanged

LineEnd: local

View:
	//depot/poc/... //p4_imp_poc/...

"@

$spec | p4 client -i
Write-Host "Client p4_imp_poc root: $root"
p4 info
p4 login -s
