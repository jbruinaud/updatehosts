#Path to hosts file
$rHost = 'C:\Windows\System32\drivers\etc\hosts'
#List of vm names
$vms=@("JBCXVM","JBUBU")
foreach($vm in $vms){
	$line = Get-VM | Get-VMNetworkAdapter | ft VMName, IPAddresses | findstr /i $vm
	if($line){
		$line = $line -replace '\s',''
		$linesplit = $line.Split("{").Split(",")
		$ip = $linesplit[1]
		$newEntry = "$ip $vm"
		$hostEntry = Get-Content $rHost | Select-String $vm
		if($hostEntry){
			if($hostEntry -like $newEntry ){
				Write-host "$hostEntry is correct"
			}
			else {
				Write-host "Updating $hostEntry with $newEntry"
				(Get-Content $rHost) | Select-String $hostEntry -notmatch | Out-File $rHost
				Add-Content $rHost "`n$newEntry"
			}
		}
		else{
			Write-host "'$vm' not found in $rHost"
			Write-host "Adding new entry $newEntry"
			Add-Content $rHost "`n$newEntry`n"
		}
	}
	else{
		Write-host "'$vm' not found in Hyper-V"
	}
}
(Get-Content $rHost) | ? {$_.trim() -ne "" } | Out-File $rHost
pause