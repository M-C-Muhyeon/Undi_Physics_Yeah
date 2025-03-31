
# 💀 Requires Administrator Privileges
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Write-Host ">>> Rolling back potentially unsafe configurations..." -ForegroundColor Red

# Remove TdrLevel setting
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrLevel /f | Out-Null

# Remove DXVA disable flag
reg delete "HKCU\Software\Microsoft\MediaPlayer\Preferences" /v EnableDXVA /f | Out-Null

# Restore usefirmwarepcisettings (not truly restorable, but prevent override)
bcdedit /deletevalue usefirmwarepcisettings

# Optional: remove truncatememory if set
bcdedit /deletevalue truncatememory

# Optional: reset kernel memory settings
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PoolUsageMaximum /f | Out-Null
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v PagedPoolSize /f | Out-Null
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /f | Out-Null

Write-Host "✅ Aggressive GPU and memory kernel tuning settings rolled back." -ForegroundColor Green
Write-Host "`n🧯 RESTORE COMPLETE — System stability should return after reboot. 🧯" -ForegroundColor Cyan
