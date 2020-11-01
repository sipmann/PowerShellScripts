<#
    .SYNOPSIS
        A utils file, contains a few helper functions

    .DESCRIPTION
        Available functions are
			- Get-AndSetPassword
			- Send-Email
#>


function Get-AndSetPassword () {
	param (
		[Parameter()]
		[string]$FilePath,
		
		[Parameter()]
		[string]$AskText,

		[Parameter()]
		[int]$SecureString=0
	)

	$pass = ''

	if (Test-Path "${FilePath}" -PathType Leaf) {
		$pass = Get-Content $FilePath | ConvertTo-SecureString
	} else {
		$pass = Read-Host "${AskText}" -AsSecureString
		ConvertFrom-SecureString $pass | Set-Content $FilePath
	}

	<# Must be a better way to do that#>
	if (-Not $SecureString) {
		$pass = (New-Object System.Net.NetworkCredential($null, $pass, $null)).Password
	}

	return $pass
}

function Send-Email () {
	param (
		[Parameter(Mandatory=$true)]
		[string]$Title,
		
		[Parameter(Mandatory=$true)]
		[string]$MailTo,
		
		[Parameter()]
		[string]$Body,
		
		[Parameter()]
		[System.Data.DataTable]$Table
	)


	Send-MailMessage -To $MailTo -From $MailFrom  -Subject 'Problemas na replicação' -bodyAsHtml $MailBody -Credential (Get-Credential) -SmtpServer 'smtp.office365.com' -Port 587 -UseSsl
}



#region INFO
    #Version : 1.2
    #Author : Lipinski, Grzegorz
	#Date : August 3, 2017
	#Url  : https://www.powershellbros.com/create-table-function-working-data-tables-powershell/

	#.EXAMPLE
		# Create-Table -TableName TABLE -ColumnNames "Username,Password"
		# $TABLE.Rows.Add("Sipmann", "123")
		# $TABLE.Rows.Add("Lais", "124")
#endregion
#region function Create-Table
function Create-Table {
	#region Parameters
		param(
			[Parameter(Mandatory=$true)]
			[string]$TableName,
			[Parameter(Mandatory=$true)]
			$ColumnNames
		)
	#endregion
	#region Validate ColumnNames data type
		if ($ColumnNames.GetType().Name -eq "String") {
			$ColumnNames = $ColumnNames -split "," #convert provided string to array
		} elseif ($ColumnNames.GetType().BaseType.Name -ne "Array") {
			Write-Error "ColumnNames parameters accepts only String or Array value."
			break
		}
	#endregion
	#region Set variables
		$TempTable = New-Object System.Data.DataTable
		$Count = 0
	#endregion
	#region Temp Table construction
		if ($ColumnNames.count -ne 0) {
			do {
				Remove-Variable -Name datatype -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
				$TempTable.Columns.Add() | Out-Null #add a column to the Temp Table
				#region if data type specified for current column
					if ($ColumnNames[$Count] -like "*/?*") {
						$datatype = $ColumnNames[$Count].Substring($ColumnNames[$Count].IndexOf("/?")+2)
						$ColumnNames[$Count] = $ColumnNames[$Count].Substring(0,$ColumnNames[$Count].IndexOf("/?"))
						if ($datatype -notlike "System.*") {
							$datatype = "System."+$datatype
						}
						$TempTable.Columns[$Count].DataType = $datatype
					}
				#endregion
				$TempTable.Columns[$Count].ColumnName = $ColumnNames[$Count] #set Temp Table empty column Name
				$TempTable.Columns[$Count].Caption = $ColumnNames[$Count] #set Temp Table empty column Caption
				$Count++ #change Count + 1 to select next Column Name to add into the Temp Table
			} until ($Count -eq $ColumnNames.Count)
		}
	#endregion
	#region Copy created Temp Table to the table with a name created by user and remove Temp Table
		Set-Variable -Name $TableName -Scope Global -Value (New-Object System.Data.DataTable)
		Set-Variable -Name $TableName -Scope Global -Value $TempTable
		Remove-Variable -Name TempTable -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	#endregion
}
#endregion

Export-ModuleMember -Function Get-AndSetPassword
Export-ModuleMember -Function Send-Email
Export-ModuleMember -Function Create-Table #use only if you create a module (".psm1")