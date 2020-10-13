<#
   Variables definition
#>
$MaxSeconds = 120  # Max seconds behind master allowed
$MysqlUser  = 'root'
$MysqlPass  = ''

$MailTo     = 'mauricio@sipmann.com'
$MailFrom   = 'mauricio@sipmann.com'


$data = $(mysql -u $MysqlUser -p"$MysqlPass" -e 'SHOW SLAVE STATUS \G')

#Debug data
#$data = Get-Content 'c:\temp\sampleresult.txt'

<# Parse the data #>
$IORunning   = (($data | Where-Object { $_ -match 'Slave_IO_Running:' }) -split '\s+')[2]
$SQLRunning  = (($data | Where-Object { $_ -match 'Slave_SQL_Running:' }) -split '\s+')[2]
$LastErrNo   = (($data | Where-Object { $_ -match 'Last_Errno' }) -split '\s+')[2]
$SecondsBh   = [int](($data | Where-Object { $_ -match 'Seconds_Behind_Master' }) -split '\s+')[2]

If ($IORunning -Eq 'No' -Or $SQLRunning -Eq 'No' -Or $SecondsBh -gt $MaxSeconds) {
	$MailBody = '<h1>Problema na replicação</h1><br>'
	
	$MailBody += '    IO Running: ' + ($IORunning)  + '<br>'
	$MailBody += '   SQL Running: ' + ($SQLRunning) + '<br>'
	$MailBody += 'Seconds Behind: ' + ($SecondsBh) + '<br>'
	$MailBody += '   Last Err No: ' + ($LastErrNo) + '<br>'
	
	<# Send e-mail, maybe some telegram message here too #>
	Send-MailMessage -To $MailTo -From $MailFrom  -Subject 'Problemas na replicação' -bodyAsHtml $MailBody -Credential (Get-Credential) -SmtpServer 'smtp.office365.com' -Port 587 -UseSsl
} Else {
    Write-Host "Up and running"
}