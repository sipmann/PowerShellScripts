<#
    .SYNOPSIS
        A script to monitor MySQL Service for restarts and 
        send messages when a restart it's noticed
#>
Import-Module '..\utils.psm1'

$data = $(mysql -h $MysqlHost -u $MysqlUser -p"$MysqlPass" -e "SHOW GLOBAL STATUS LIKE 'Uptime' \G")

<# Unable to execute the sql Command #>
if ($lastExitCode -eq 1) {
	Send-MailMessage -To $MailTo -From $MailFrom  -Subject 'Problemas de conexão' -bodyAsHtml "Falha na conexão com host ${$MysqlHost}" -Credential $MailCred -SmtpServer 'smtp.office365.com' -Port 587 -UseSsl
	exit
}

$UpTime   = [int](($data | Where-Object { $_ -match 'Value:' }) -split '\s+')[2]

<# If the uptime is lower then 20 minutes #>
if ($UpTime -lt 1200) {
    Send-Email -MailTo -Title "MySQL Reiniciado" -Body "MySQL do host ${MysqlHost} foi reiniciado em menos de 20 minutos"
}