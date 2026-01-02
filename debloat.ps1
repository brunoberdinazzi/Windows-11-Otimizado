#requires -RunAsAdministrator
<#
Win11 Pro Debloat (seguro):
- Remove apps "inbox" comuns (usuário(s) + provisionadas)
- Aplica políticas em HKLM (valem pro dispositivo)
- Prepara um script de 1º login para aplicar políticas em HKCU (por usuário)
Log: C:\Windows\Setup\Scripts\debloat.log (se rodar via SetupComplete.cmd)
#>

$ErrorActionPreference = "SilentlyContinue"

# ====== TOGGLES ======
$ENABLE_NATIVE_NVME = $true   # ATENÇÃO: tweak experimental (Native NVMe). Leia o README antes.

$REMOVE_XBOX = $true
$REMOVE_PHONE_LINK = $true
$REMOVE_TEAMS_PERSONAL = $true

# ====== LISTA ======
$patterns = @(
  "*Clipchamp*",
  "*Microsoft.BingNews*",
  "*Microsoft.BingWeather*",
  "*Microsoft.WindowsFeedbackHub*",
  "*Microsoft.GetHelp*",
  "*Microsoft.Getstarted*",
  "*Microsoft.MicrosoftSolitaireCollection*",
  "*Microsoft.People*",
  "*Microsoft.Todos*",
  "*Microsoft.PowerAutomateDesktop*"
)

if ($REMOVE_TEAMS_PERSONAL) { $patterns += "*MicrosoftTeams*" }
if ($REMOVE_PHONE_LINK)     { $patterns += "*Microsoft.YourPhone*" }
if ($REMOVE_XBOX)           { $patterns += "*Microsoft.GamingApp*"; $patterns += "*Microsoft.Xbox*" }

# Dependências a manter (Store/winget/runtime)
$doNotTouch = @(
  "Microsoft.WindowsStore",
  "Microsoft.StorePurchaseApp",
  "Microsoft.DesktopAppInstaller",
  "Microsoft.VCLibs",
  "Microsoft.UI.Xaml",
  "Microsoft.NET.Native.Framework",
  "Microsoft.NET.Native.Runtime"
)

function ShouldSkip([string]$name) {
  foreach ($k in $doNotTouch) {
    if ($name -like "$k*") { return $true }
  }
  return $false
}

Write-Host "== Políticas (HKLM) =="
# Turn off Microsoft consumer experiences
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f | Out-Null

# Forçar apps UWP a NÃO rodarem em background (Force Deny)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d 2 /f | Out-Null

# Turn off Windows Copilot (política do dispositivo)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f | Out-Null

Write-Host "== Removendo apps do(s) usuário(s) existentes (Remove-AppxPackage) =="
foreach ($p in $patterns) {
  Get-AppxPackage -AllUsers $p | ForEach-Object {
    if (-not (ShouldSkip $_.Name)) {
      Write-Host "Removendo (user): $($_.Name)"
      Remove-AppxPackage -Package $_.PackageFullName -AllUsers
    }
  }
}

Write-Host "== Removendo apps provisionados (Remove-AppxProvisionedPackage) =="
foreach ($p in $patterns) {
  Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $p } | ForEach-Object {
    if (-not (ShouldSkip $_.DisplayName)) {
      Write-Host "Deprovision: $($_.DisplayName)"
      Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName | Out-Null
    }
  }
}

Write-Host "== Preparando script de 1º login (HKCU) =="
$dir = "C:\ProgramData\Win11Clean"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$firstLogin = @'
# Aplica políticas por-usuário (HKCU)
# "Do not use diagnostic data for tailored experiences"
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableTailoredExperiencesWithDiagnosticData" /t REG_DWORD /d 1 /f | Out-Null
'@

Set-Content -Path "$dir\FirstLogin.ps1" -Value $firstLogin -Encoding UTF8

# Cria RunOnce para o próximo logon de qualquer usuário
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "Win11Clean_FirstLogin" /t REG_SZ /d "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$dir\FirstLogin.ps1`"" /f | Out-Null

Write-Host "== Fim =="
