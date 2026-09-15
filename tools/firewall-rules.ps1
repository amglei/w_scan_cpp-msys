#Requires -RunAsAdministrator
# w_scan_cpp + SSDP Firewall-Regeln (Profil Privat + Oeffentlich).
# Komplett in eine PowerShell MIT Admin-Rechten pasten und ausfuehren.
$ErrorActionPreference = 'Stop'

$distExe  = '.\dist\w_scan_cpp-msys-x86_64\w_scan_cpp.exe'
$buildExe = '.\w-scan-cpp-20260515+dfsg\w_scan_cpp.exe'

# 1) Alte Public-only w_scan-Regeln aufraeumen (werden unten neu angelegt)
Get-NetFirewallRule -DisplayName 'w_scan_cpp*' -ErrorAction SilentlyContinue | Remove-NetFirewallRule

# 2) Programm-Regeln: RTP/RTCP nutzt ephemere Ports -> ALLE lokalen Ports
#    freigeben, aber nur fuer dieses Programm (TCP+UDP, Privat+Oeffentlich)
foreach ($item in @(@{Name='dist'; Exe=$distExe}, @{Name='build'; Exe=$buildExe})) {
  if (-not (Test-Path $item.Exe)) { Write-Warning "nicht gefunden (Regel wird trotzdem angelegt): $($item.Exe)" }
  New-NetFirewallRule -DisplayName "w_scan_cpp $($item.Name) (TCP)" -Direction Inbound `
    -Program $item.Exe -Protocol TCP -Profile Private,Public -Action Allow -Enabled True | Out-Null
  New-NetFirewallRule -DisplayName "w_scan_cpp $($item.Name) (UDP)" -Direction Inbound `
    -Program $item.Exe -Protocol UDP -Profile Private,Public -Action Allow -Enabled True | Out-Null
}

# 3) SSDP-Discovery (UDP 1900, programm-unabhaengig, Privat+Oeffentlich)
Get-NetFirewallRule -DisplayName 'SSDP Inbound (UDP 1900)' -ErrorAction SilentlyContinue | Remove-NetFirewallRule
New-NetFirewallRule -DisplayName 'SSDP Inbound (UDP 1900)' -Direction Inbound `
  -Protocol UDP -LocalPort 1900 -Profile Private,Public -Action Allow -Enabled True | Out-Null

# 4) Kontrolle
Get-NetFirewallRule -DisplayName 'w_scan_cpp*', 'SSDP Inbound (UDP 1900)' |
  Select-Object DisplayName, Enabled, Profile, Action | Format-Table -AutoSize
