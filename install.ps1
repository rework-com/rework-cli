# Install the Rework CLI from GitHub Releases (Windows).
#   irm https://github.com/rework-com/rework-cli/releases/latest/download/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$repo = 'rework-com/rework-cli'
$url  = "https://github.com/$repo/releases/latest/download/rework-windows-x64.exe"
$dest = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'   # on PATH from login -> works in any new terminal
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Write-Host "Downloading rework-windows-x64.exe ..."
Invoke-WebRequest -Uri $url -OutFile (Join-Path $dest 'rework.exe')
Write-Host "Installed -> $(Join-Path $dest 'rework.exe')"
Write-Host "Open a NEW terminal, then:  rework auth login"
