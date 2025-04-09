#  Copyright 2012-2025 Stanislav Senotrusov
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# Stop execution on all errors
$ErrorActionPreference = "Stop"

# Configure the system clock to use UTC time
New-ItemProperty -Path 'HKLM:SYSTEM\CurrentControlSet\Control\TimeZoneInformation' `
  -Name RealTimeIsUniversal -Value 1 -PropertyType DWORD -Force

# Allow execution of untrusted scripts for this session
Write-Output "Setting execution policy..."
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Chocolatey if it's not already installed
if (-Not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
  Write-Output "Installing Chocolatey..."
  [System.Net.ServicePointManager]::SecurityProtocol = `
    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
}

# Verify that Chocolatey was successfully installed
if (-Not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
  throw "Chocolatey installation failed: 'choco' not found in path."
}

# Enable global confirmation to avoid interactive prompts
choco feature enable -n allowGlobalConfirmation
if ($LASTEXITCODE -ne 0) { throw "Failed to enable global confirmation in Chocolatey." }

# Disable download progress if running in a CI environment
if ($env:CI -eq "true") {
  choco feature disable -n showDownloadProgress
  if ($LASTEXITCODE -ne 0) { throw "Failed to disable download progress in Chocolatey." }
}

# Helper function to install a Chocolatey package with error checking
function Choco-Install {
  choco install $args
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install package: $args"
  }
}

# Upgrade all existing packages (only outside CI)
if ($env:CI -ne "true") {
  Write-Output "Upgrading all existing Chocolatey packages..."
  choco upgrade all --yes
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to upgrade Chocolatey packages."
  }
}

# == Install selected packages ==

# GPU drivers (only when not in CI)
if ($env:CI -ne "true") {
  Choco-Install nvidia-display-driver
}

# Communication
Choco-Install discord  # Proprietary

# Web browsers
# Choco-Install googlechrome --ignore-checksums  # Proprietary
# Choco-Install chromium
Choco-Install firefox

# Productivity tools
# Choco-Install libreoffice-still

# Content creation tools
Choco-Install avidemux
Choco-Install krita
Choco-Install streamlabs-obs
Choco-Install tenacity

# Media consumption
# Choco-Install spotify --ignore-checksums  # Proprietary
Choco-Install vlc

# File storage and management
# Choco-Install restic
# Choco-Install winscp
Choco-Install 7zip   # Note: partially under unRAR license
Choco-Install synctrayzor
Choco-Install windirstat

# Code editors
# Choco-Install meld
# Choco-Install sublimemerge  # Proprietary
# Choco-Install vscode        # Proprietary

# Developer tools
# Choco-Install git
# Choco-Install nodejs

# Networking tools
# Choco-Install curl

# System monitoring
Choco-Install librehardwaremonitor

# Benchmarking tools
# Choco-Install crystaldiskmark
