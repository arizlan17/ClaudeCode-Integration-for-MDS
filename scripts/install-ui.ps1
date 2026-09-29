# Window for installing the Claude + Helix connector.
# Double-click "Install Claude Helix.cmd" in the package root.
# Helix Auth still opens the company browser. This window starts that login; it does not type it.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:loginProcess = $null

function Add-Log {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return }
    $logBox.AppendText($Text.TrimEnd() + [Environment]::NewLine)
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.ScrollToCaret()
}

function Get-FieldMap {
    $map = @{}
    foreach ($pair in @(
            @{ Box = $portBox; Key = "P4PORT" },
            @{ Box = $userBox; Key = "P4USER" },
            @{ Box = $clientBox; Key = "P4CLIENT" }
        )) {
        $map[$pair.Key] = $pair.Box.Text.Trim()
    }
    return $map
}

function Read-KeyFile {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path -LiteralPath $Path)) { return $map }
    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $parts = $line.Split("=", 2)
            $map[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
    return $map
}

function Import-Destination {
    $dest = $destBox.Text.Trim()
    if (-not $dest -or -not (Test-Path -LiteralPath $dest)) { return }
    $cfg = Read-KeyFile (Join-Path $dest ".p4config")
    $lines = Read-KeyFile (Join-Path $dest ".claude\helix-lines.local")
    if ($cfg["P4PORT"]) { $portBox.Text = $cfg["P4PORT"] }
    if ($cfg["P4USER"]) { $userBox.Text = $cfg["P4USER"] }
    if ($cfg["P4CLIENT"]) { $clientBox.Text = $cfg["P4CLIENT"] }
    if ($lines["MAIN"]) { $mainBox.Text = $lines["MAIN"] }
    if ($lines["DEV"]) { $devBox.Text = $lines["DEV"] }
    if ($lines["FEATURES"]) { $featuresBox.Text = $lines["FEATURES"] }
}

function Test-Ready {
    $missing = @()
    if (-not $destBox.Text.Trim()) { $missing += "client folder" }
    if (-not $portBox.Text.Trim()) { $missing += "Helix server" }
    if (-not $userBox.Text.Trim()) { $missing += "user" }
    if (-not $clientBox.Text.Trim()) { $missing += "client name" }
    if (-not $mainBox.Text.Trim().StartsWith("//")) { $missing += "main path (must start with //)" }
    if (-not $devBox.Text.Trim().StartsWith("//")) { $missing += "dev path (must start with //)" }
    if (-not $featuresBox.Text.Trim().StartsWith("//")) { $missing += "features path (must start with //)" }
    if ($missing.Count -gt 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Fill in: " + ($missing -join ", "),
            "Claude + Helix setup",
            "OK",
            "Warning"
        ) | Out-Null
        return $false
    }
    return $true
}

function Get-P4Exe {
    $cmd = Get-Command p4 -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Add-Log "FAIL  P4 CLI is not on PATH. Install the Helix command line, then open this window again."
        return $null
    }
    return $cmd.Source
}

function New-P4Process {
    param([string[]]$ArgumentList)
    $exe = Get-P4Exe
    if (-not $exe) { return $null }
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.WorkingDirectory = $destBox.Text.Trim()
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.EnvironmentVariables["P4CONFIG"] = ".p4config"
    $psi.Arguments = ($ArgumentList | ForEach-Object {
            if ($_ -match '\s') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
        }) -join " "
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    return $process
}

function Invoke-P4 {
    param([string[]]$ArgumentList)
    $process = New-P4Process -ArgumentList $ArgumentList
    if (-not $process) { return $null }
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    return @{ Code = $process.ExitCode; Out = ($stdout + $stderr).Trim() }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Claude + Helix setup"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.ClientSize = New-Object System.Drawing.Size(640, 700)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

$intro = New-Object System.Windows.Forms.Label
$intro.Text = "Installs Claude Code into a Helix client folder. Sign-in opens the company browser once. Claude Code still needs one approval click for perforce-p4-mcp."
$intro.Location = New-Object System.Drawing.Point(16, 12)
$intro.Size = New-Object System.Drawing.Size(608, 48)
$form.Controls.Add($intro)

function Add-LabeledBox {
    param([string]$Caption, [int]$Top, [switch]$Browse)
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Caption
    $label.Location = New-Object System.Drawing.Point(16, $Top)
    $label.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($label)
    $box = New-Object System.Windows.Forms.TextBox
    $box.Location = New-Object System.Drawing.Point(16, ($Top + 20))
    if ($Browse) { $box.Size = New-Object System.Drawing.Size(500, 24) } else { $box.Size = New-Object System.Drawing.Size(608, 24) }
    $form.Controls.Add($box)
    return $box
}

$destBox = Add-LabeledBox "Client folder" 64 -Browse
$browse = New-Object System.Windows.Forms.Button
$browse.Text = "Browse"
$browse.Location = New-Object System.Drawing.Point(524, 84)
$browse.Size = New-Object System.Drawing.Size(100, 26)
$form.Controls.Add($browse)

$portBox = Add-LabeledBox "Helix server (example: ssl:helix.company.com:1666)" 120
$userBox = Add-LabeledBox "Helix user (standard user)" 176
$clientBox = Add-LabeledBox "Client name" 232
$mainBox = Add-LabeledBox "Main depot path" 288
$devBox = Add-LabeledBox "Dev depot path" 344
$featuresBox = Add-LabeledBox "Features depot path" 400

$buttonRow = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonRow.Location = New-Object System.Drawing.Point(16, 456)
$buttonRow.Size = New-Object System.Drawing.Size(608, 36)
$buttonRow.WrapContents = $false
$form.Controls.Add($buttonRow)

function Add-ActionButton {
    param([string]$Caption)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Caption
    $button.AutoSize = $true
    $button.Height = 30
    $button.Margin = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
    $buttonRow.Controls.Add($button)
    return $button
}

$installButton = Add-ActionButton "1. Install"
$trustButton = Add-ActionButton "2. Trust server"
$loginButton = Add-ActionButton "3. Sign in"
$checkButton = Add-ActionButton "4. Check"
$openButton = Add-ActionButton "Open folder"

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(16, 504)
$logBox.Size = New-Object System.Drawing.Size(608, 180)
$logBox.Multiline = $true
$logBox.ReadOnly = $true
$logBox.ScrollBars = "Vertical"
$logBox.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($logBox)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 400

$browse.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Choose the Helix client root"
    if ($destBox.Text.Trim() -and (Test-Path -LiteralPath $destBox.Text.Trim())) {
        $dialog.SelectedPath = $destBox.Text.Trim()
    }
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $destBox.Text = $dialog.SelectedPath
        Import-Destination
        Add-Log "Folder: $($destBox.Text)"
    }
})

$destBox.Add_Leave({ Import-Destination })

$installButton.Add_Click({
    if (-not (Test-Ready)) { return }
    $installer = Join-Path $PSScriptRoot "install-into-workspace.ps1"
    if (-not (Test-Path -LiteralPath $installer)) {
        Add-Log "FAIL  Missing $installer"
        return
    }
    try {
        & $installer `
            -Destination $destBox.Text.Trim() `
            -P4Port $portBox.Text.Trim() `
            -P4User $userBox.Text.Trim() `
            -P4Client $clientBox.Text.Trim() `
            -MainPath $mainBox.Text.Trim() `
            -DevPath $devBox.Text.Trim() `
            -FeaturesPath $featuresBox.Text.Trim()
        Add-Log "Installed into $($destBox.Text.Trim())"
        Add-Log "Next: Trust server, then Sign in. Sign-in opens the browser."
    } catch {
        Add-Log "FAIL  $($_.Exception.Message)"
    }
})

$trustButton.Add_Click({
    $dest = $destBox.Text.Trim()
    if (-not (Test-Path -LiteralPath (Join-Path $dest ".p4config"))) {
        Add-Log "Click Install first."
        return
    }
    if ($portBox.Text.Trim() -notlike "ssl:*") {
        Add-Log "OK  This server is not ssl. Trust is only needed for an ssl: port."
        return
    }
    Add-Log "Trusting $($portBox.Text.Trim()) ..."
    $result = Invoke-P4 -ArgumentList @("-d", $dest, "trust", "-y")
    if ($null -eq $result) { return }
    if ($result.Out) { Add-Log $result.Out }
    if ($result.Code -eq 0) { Add-Log "OK  Server trusted on this PC." } else { Add-Log "FAIL  p4 trust exited $($result.Code)" }
})

$loginButton.Add_Click({
    $dest = $destBox.Text.Trim()
    if (-not (Test-Path -LiteralPath (Join-Path $dest ".p4config"))) {
        Add-Log "Click Install first."
        return
    }
    if ($script:loginProcess -and -not $script:loginProcess.HasExited) {
        Add-Log "Sign-in is already waiting for the browser."
        return
    }
    $process = New-P4Process -ArgumentList @("-d", $dest, "login")
    if (-not $process) { return }
    $script:loginProcess = $process
    [void]$process.Start()
    $loginButton.Enabled = $false
    Add-Log "Waiting for Helix Auth. Finish sign-in in the browser window."
    $timer.Start()
})

$timer.Add_Tick({
    if (-not $script:loginProcess -or -not $script:loginProcess.HasExited) { return }
    $timer.Stop()
    $loginButton.Enabled = $true
    $stdout = ""
    $stderr = ""
    try { $stdout = $script:loginProcess.StandardOutput.ReadToEnd() } catch { }
    try { $stderr = $script:loginProcess.StandardError.ReadToEnd() } catch { }
    $text = ($stdout + $stderr).Trim()
    if ($text) { Add-Log $text }
    $dest = $destBox.Text.Trim()
    $check = Invoke-P4 -ArgumentList @("-d", $dest, "login", "-s")
    if ($null -eq $check) { return }
    if ($check.Code -eq 0) {
        Add-Log "OK  $($check.Out)"
        Add-Log "Open this client folder in Claude Code and approve perforce-p4-mcp."
    } else {
        Add-Log "FAIL  Sign-in did not finish. $($check.Out)"
    }
})

$checkButton.Add_Click({
    $dest = $destBox.Text.Trim()
    $checker = Join-Path $dest "scripts\check-enterprise.ps1"
    if (-not (Test-Path -LiteralPath $checker)) {
        Add-Log "Click Install first."
        return
    }
    $outFile = Join-Path $env:TEMP "claude-helix-check-out.txt"
    $errFile = Join-Path $env:TEMP "claude-helix-check-err.txt"
    $proc = Start-Process -FilePath "powershell.exe" -PassThru -Wait -WindowStyle Hidden `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$checker`"" `
        -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    if (Test-Path $outFile) { Add-Log (Get-Content -LiteralPath $outFile -Raw) }
    if (Test-Path $errFile) { Add-Log (Get-Content -LiteralPath $errFile -Raw) }
    if ($proc.ExitCode -eq 0) { Add-Log "Check finished." } else { Add-Log "Check reported a problem. See the lines above." }
})

$openButton.Add_Click({
    $dest = $destBox.Text.Trim()
    if (-not $dest -or -not (Test-Path -LiteralPath $dest)) {
        Add-Log "Choose a client folder first."
        return
    }
    Start-Process -FilePath explorer.exe -ArgumentList "`"$dest`""
})

$form.Add_FormClosing({
    $timer.Stop()
    if ($script:loginProcess -and -not $script:loginProcess.HasExited) {
        try { $script:loginProcess.Kill() } catch { }
    }
})

Add-Log "Choose the client folder, fill in the Helix values, then use the buttons in order."
[void]$form.ShowDialog()
