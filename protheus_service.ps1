param($Acao = 'restart')

$servicesNames = 'app_main',
    'app_worker1',
    'app_worker2',
    'app_worker3',
    'app_worker4',
    'app_worker5'

switch($Acao) {
    'restart' {
        Write-host 'Reiniciando Serviços'; 
        break;
    }
    'manutencao' {
        Write-Host 'Parando Serviços';
        
        <# Adiciona os demais serviços #>
        $servicesNames += 'TOTVS-Appserver12|SCHEDULE'
        $servicesNames += 'TOTVS-Appserver12|WF'
        break;
    }
    default {
        Write-Host "Ação '$Acao' desconhecida.";
        exit;
    }
}
Write-host "--------------------------"

foreach ($srv in $servicesNames) {
    Write-host "Stopping: " + $srv
    $SrvPID = (get-wmiobject win32_service | Where-Object { $_.name -eq $srv}).processID
    Write-host "PID: " + $SrvPID

    <# Force if the proccess is stucked #>
    Stop-Process $SrvPID -Force
    Write-host "PDI " + $SrvPID + " stopped"
}

if ($Acao -eq 'manutencao') {
    Write-Host -NoNewline 'Pressione alguma tecla para subir os serviços'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

Write-host "Starting Services"
Write-host "--------------------------"

foreach ($srv in $servicesNames) {
    Write-host "Starting: " + $srv
    Start-Service $srv
}
