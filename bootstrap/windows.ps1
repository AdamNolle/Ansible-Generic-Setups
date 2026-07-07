# Windows preflight for Ansible-Generic-Setups.
#
# Windows can't run Ansible itself, so this script prepares the machine to be
# provisioned OVER SSH from a control node (a Mac/Linux box, or WSL). It:
#   1. installs + starts the OpenSSH Server,
#   2. opens the firewall for SSH,
#   3. sets PowerShell as the default SSH shell (Ansible needs this),
#   4. prints the exact command to run from your control node.
#
# Run in an ELEVATED PowerShell:  irm <raw-url>/bootstrap/windows.ps1 | iex
# (or copy this file over and run it).

$ErrorActionPreference = 'Stop'

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw "Run this in an elevated (Administrator) PowerShell."
}

Write-Host "==> Installing the OpenSSH Server" -ForegroundColor Cyan
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue | Out-Null
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

Write-Host "==> Opening the firewall for SSH (TCP 22)" -ForegroundColor Cyan
if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' `
    -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
}

Write-Host "==> Setting PowerShell as the default SSH shell" -ForegroundColor Cyan
$pwsh = (Get-Command powershell.exe).Source
New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $pwsh `
  -PropertyType String -Force | Out-Null

$ip = (Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
  Select-Object -First 1).IPAddress

Write-Host ""
Write-Host "==> This PC is ready to provision." -ForegroundColor Green
Write-Host "On your control node (Mac/Linux/WSL) with this repo cloned, edit"
Write-Host "inventory/hosts.yml so the 'windows' host has:" -ForegroundColor Yellow
Write-Host "    ansible_host: $ip"
Write-Host "    ansible_user: $env:USERNAME"
Write-Host "then run:" -ForegroundColor Yellow
Write-Host "    ansible-playbook site.yml --limit windows -K -e win_profile=standard"
