<#

.DESCRIPTION
	Based on https://www.fluxbytes.com/powershell/using-powershell-to-backup-your-mysql-databases/

#>
function LogMessage([string] $msg)
{
	$logOutput = [string]::Format("{0} >> {1}", (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg);
	Out-File $logFileFullPath -InputObject $logOutput -Append;
}

function GetCurrentDateTime
{
    return Get-Date -Format yyyyMMdd_HHmmss;
}

 
$debugMode = $false;  # Show errors from mysqldump
 
$databaseBackupLocation = "B:\Backup\mysql\";  
$logFileName = "backup_log.log";  # Filename of the log file
$logFileFullPath = [io.path]::combine($databaseBackupLocation, $logFileName);  # The full path of the log file (ignore this, it will get populated from the 2 variables above)

#$mysqlDumpLocation = "C:\MySQL\mysqldump.exe";  # Path to the mysqldump executable. This is required in order to be able to dump the databases.
$mysqlDumpLocation = "mysqlsh.exe";  # Path to the mysqldump executable. This is required in order to be able to dump the databases.
$falhou = $false;
 
$databaseIp = "127.0.0.1";  # Database IP or Hostname
$databaseUsername = "backup";  # Database username (it should have the basic permissions https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)
$databasePassword = "";  # The password of the user
 
<# Here is the database list #>
$databases = 'glpi_tiab',
			'zabbix';
 
md -Force $databaseBackupLocation | Out-Null  # Create the path for the log file

LogMessage "-------------------------------------------------"
LogMessage "Starting backup operation";
 
# Iterate and process all the database entries
foreach ($database in $databases)
{
    try
    {
        LogMessage ([string]::Format("[{0}] Starting backup...",$database));
        $date = GetCurrentDateTime;
		
		$backupPath = [io.path]::combine($databaseBackupLocation, $database);
        md -Force $backupPath | Out-Null
        $saveFilePath = [string]::format("{0}\{1}_{2}", $backupPath, $database, $date);
        
        $command = [string]::format("`"{0}`" {1}:{2}@{3} -- util dumpSchemas {4} --output-url {5} --threads 8",
            $mysqlDumpLocation,
            $databaseUsername,
            $databasePassword,
            $databaseIp,
            $database,
            $saveFilePath);
 
        $mysqlDumpError;
        Invoke-Expression "& $command" -ErrorVariable mysqlDumpError;  # Execute mysqldump with the required parameters for each database
 
        # If debug mode is on then you will see the errors mysqldump generates in the log file.
        if ($debugMode -eq $true)
        {
            LogMessage $mysqlDumpError;
        }
        
        $logEntry = [string]::Format("[{0}] Successfully backed up", $database);
        LogMessage $logEntry;
    }
    catch [Exception]
    {        
        $exceptionMessage = $_.Exception.Message;
        $logEntry = [string]::Format("[{0}] Failed to backup up. Reason: {1}", $database, $exceptionMessage);
        LogMessage $logEntry;
		$falhou = $true;
    }
}
 
LogMessage "Backup operation completed";

If ($falou -eq $false)
{
	<# Pign the Healthcheck.io endpoint #>
	Invoke-RestMethod https://hc-ping.com/123
}