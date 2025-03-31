# 💀 Requires Administrator Privileges
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Write-Host ">>> Disabling Microsoft background services and tracking features..." -ForegroundColor Red

# 1. Disable unnecessary services
$servicesToDisable = @(
    "DiagTrack", "SysMain", "WSearch", "XblGameSave", "XboxNetApiSvc", "XblAuthManager",
    "OneSyncSvc", "CDPSvc", "MapsBroker", "Fax", "RetailDemo"
)

foreach ($svc in $servicesToDisable) {
    Get-Service -Name $svc -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Status -ne 'Stopped') {
            Stop-Service -Name $_.Name -Force
        }
        Set-Service -Name $_.Name -StartupType Disabled
        Write-Host "$($_.Name) stopped and disabled" -ForegroundColor Green
    }
}

# 2. Defender realtime protection off
Write-Host "`n>>> Disabling Windows Defender realtime protection..." -ForegroundColor Red
Set-MpPreference -DisableRealtimeMonitoring $true
Write-Host "✅ Defender realtime protection disabled" -ForegroundColor Green

# 3. Windows Update off
Write-Host "`n>>> Disabling Windows Update service..." -ForegroundColor Red
Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Set-Service -Name "wuauserv" -StartupType Disabled
Write-Host "✅ Windows Update disabled" -ForegroundColor Green

# 4. Disable telemetry tasks
Write-Host "`n>>> Disabling telemetry-related scheduled tasks..." -ForegroundColor Red
$tasks = @(
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
)

foreach ($task in $tasks) {
    $exists = schtasks /Query /TN $task 2>$null
    if ($LASTEXITCODE -eq 0) {
        schtasks /Change /TN $task /Disable | Out-Null
        Write-Host "✅ Task $task disabled" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Task $task not found or already removed" -ForegroundColor DarkGray
    }
}

# 5. Disable Cortana / Widgets / Edge
Write-Host "`n>>> Disabling Cortana / Widgets / Edge via registry..." -ForegroundColor Red
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v PreventFirstRunPage /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium /t REG_DWORD /d 1 /f | Out-Null
Write-Host "✅ Cortana / Widgets / Edge disabled" -ForegroundColor Green

# 6. Disable Error Reporting (WER)
Write-Host "`n>>> Disabling Windows Error Reporting..." -ForegroundColor Red
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
Write-Host "✅ Error Reporting disabled" -ForegroundColor Green

# 7. Delivery Optimization (policy only)
Write-Host "`n>>> Disabling Delivery Optimization via policy..." -ForegroundColor Red
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f | Out-Null
Write-Host "✅ Delivery Optimization policy applied" -ForegroundColor Green

# 8. Disable Cloud Clipboard & Sync
Write-Host "`n>>> Disabling Cloud Clipboard and Sync settings..." -ForegroundColor Red
reg add "HKCU\Software\Microsoft\Clipboard" /v EnableClipboardHistory /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\Clipboard" /v EnableCloudClipboard /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SyncSettings" /v Enabled /t REG_DWORD /d 0 /f | Out-Null
Write-Host "✅ Clipboard sync disabled" -ForegroundColor Green

# 9. Disable typing history / personalization
Write-Host "`n>>> Disabling typing history and input personalization..." -ForegroundColor Red
reg add "HKCU\Software\Microsoft\Input\TIPC" /v Enabled /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f | Out-Null
reg add "HKCU\Software\Microsoft\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f | Out-Null
Write-Host "✅ Input personalization disabled" -ForegroundColor Green

# 10. Disable Start menu suggestions
Write-Host "`n>>> Disabling Start menu ads / suggestions..." -ForegroundColor Red
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f | Out-Null
Write-Host "✅ Start menu ads disabled" -ForegroundColor Green

# 11. Disable scheduled maintenance tasks
Write-Host "`n>>> Disabling scheduled system maintenance..." -ForegroundColor Red
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\MaintenanceConfigurator" /Disable | Out-Null
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /Disable | Out-Null
Write-Host "✅ Scheduled maintenance tasks disabled" -ForegroundColor Green

# 12. Disable scheduled defrag on SSD
Write-Host "`n>>> Disabling scheduled defrag (for SSDs)..." -ForegroundColor Red
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
Write-Host "✅ Scheduled defrag disabled" -ForegroundColor Green

# 13. Clean up temp files and empty recycle bin
Write-Host "`n>>> Cleaning up temp files and recycle bin..." -ForegroundColor Red
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "✅ Temporary files and recycle bin cleaned" -ForegroundColor Green

# 14. Release memory manually via working set trim (RAMMap alternative)
Write-Host "`n>>> Attempting manual memory release using working set trim..." -ForegroundColor Red
Get-Process | ForEach-Object {
    try {
        $_.MinWorkingSet = 64MB
        $_.MaxWorkingSet = 128MB
    } catch {}
}
Write-Host "✅ Attempted working set trim (partial standby memory release)" -ForegroundColor Green

# 15. Enforce high performance while on battery (powercfg boost)
Write-Host "`n>>> Enforcing high performance on battery mode..." -ForegroundColor Red
powercfg /setactive SCHEME_MIN
powercfg -change standby-timeout-ac 0
powercfg -change standby-timeout-dc 0
powercfg -change monitor-timeout-dc 0
powercfg -change monitor-timeout-ac 0
powercfg -setdcvalueindex SCHEME_MIN SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setdcvalueindex SCHEME_MIN SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg -setdcvalueindex SCHEME_MIN SUB_PROCESSOR PERFINCTHRESHOLD 100
powercfg -setdcvalueindex SCHEME_MIN SUB_PROCESSOR PERFINCPOLICY 100
powercfg -setdcvalueindex SCHEME_MIN SUB_PROCESSOR PERFDECPOLICY 100
powercfg -setdcvalueindex SCHEME_MIN SUB_PROCESSOR PERFBOOSTMODE 2
Write-Host "✅ Processor boost and throttle settings forced to max" -ForegroundColor Green

# 16. Disable Windows power throttling via registry
Write-Host "`n>>> Disabling Windows power throttling registry flag..." -ForegroundColor Red
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v EnergyEstimationDisabled /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v PowerThrottlingOff /t REG_DWORD /d 1 /f | Out-Null
Write-Host "✅ Power throttling registry keys set" -ForegroundColor Green

# Final message
Write-Host "`n🔥 ULTRA HARDCORE MODE ENABLED — Microsoft neutered, Windows unleashed 🔥" -ForegroundColor Cyan

