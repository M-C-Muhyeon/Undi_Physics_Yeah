
# 💀 Requires Administrator Privileges
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Write-Host ">>> Rolling back all aggressive system tuning to restore performance..." -ForegroundColor Red

# Restore GPU fallback & video acceleration
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrLevel /f | Out-Null
reg delete "HKCU\Software\Microsoft\MediaPlayer\Preferences" /v EnableDXVA /f | Out-Null

# Reset Windows Power settings to default and activate High Performance mode
powercfg /restoredefaultschemes
powercfg -setactive SCHEME_MIN

# Reset bcdedit changes
bcdedit /deletevalue usefirmwarepcisettings
bcdedit /deletevalue truncatememory
bcdedit /deletevalue useplatformclock
bcdedit /deletevalue nolowmem

# Restore default memory management settings
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PoolUsageMaximum /f | Out-Null
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagedPoolSize /f | Out-Null
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /f | Out-Null

# Enforce LargeSystemCache OFF
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f | Out-Null

# Restore GPU scheduling/system responsiveness
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /f | Out-Null
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v GPU Priority /f | Out-Null
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /f | Out-Null

Write-Host "✅ All tuning settings reverted to default (with LargeSystemCache and power plan fixed)" -ForegroundColor Green
Write-Host "`n🧯 SYSTEM RESTORED — Performance tuning fully rolled back. Reboot recommended. 🧯" -ForegroundColor Cyan
