$servicesNames = 'app_main',
    'app_worker1',
    'app_worker2',
    'app_worker3',
    'app_worker4',
    'app_worker5'

Write-host "Stoping Services"
Write-host "--------------------------"

foreach ($srv in $servicesNames) {
    Write-host "Stopping: " + $srv
    $SrvPID = (get-wmiobject win32_service | Where-Object { $_.name -eq $srv}).processID
    Write-host "PID: " + $SrvPID

    <# Force if the proccess is stucked #>
    Stop-Process $SrvPID -Force
    Write-host "PDI " + $SrvPID + " stopped"
}


Write-host "Starting Services"
Write-host "--------------------------"

foreach ($srv in $servicesNames) {
    Write-host "Starting: " + $srv
    Start-Service $srv
}