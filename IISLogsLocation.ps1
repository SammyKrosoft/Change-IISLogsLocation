<#PSScriptInfo

.VERSION 1.0

.GUID 09fecba8-b9c0-4d20-b0cb-cf9c45fc1032

.AUTHOR SK

.COMPANYNAME Microsoft Canada

.COPYRIGHT Oct 2020 - feel free to re-use, enhance, adapt, etc...

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

<#
.DESCRIPTION 
 Check or change IIS Logs location 

.EXAMPLE
.\IISLocation.ps1 -GetIIS -Computers "Computer01", "Computer02"
Dumps the IIS log directory location for the computers specified

.EXAMPLE
.\IISLocation.ps1 -SetIIS -NewLocation D:\IISLogs -Computers "Computer01","Computer02"
Sets IIS log directory location to D:\IISLogs for the computers specified

.EXAMPLE
.\IISLocation.ps1 -SetIIS -DefaultLocation -Computers "Computer01","Computer02"
Sets the IIS Log directory to the default one, using the SystemDrive environment variable of the remote computer to get the SystemDrive environment variable of each remote computer
as if we were local.

#> 

[CmdletBinding(DefaultParameterSetName="GetInfo")]
param(
    [parameter(ParameterSetName="GetInfo")][switch]$GetIIS,
    [parameter(ParameterSetName="SetInfo")]
    [parameter(ParameterSetName="SetDefault")]
    [switch]$SetIIS,
    [parameter(ParameterSetName="SetDefault")][switch]$DefaultLocation,
    [Parameter(ParameterSetName="SetInfo")][string]$NewLogLocation = "c:\IISLogsNewLocation",
    [Parameter(ParameterSetName="SetInfo")]
    [Parameter(ParameterSetName="GetInfo")]
    [Parameter(ParameterSetName="SetDefault")]
    [string[]]$Computers
)

Import-Module WebAdministration

If (!($Computers)){
    $Computers = "$Env:COMPUTERNAME"
}

If ($SetIIS){
    ForEach ($Computer in $Computers){
               
        If ($DefaultLocation){
            Write-Host "Changing IIS Logpath of server $Computer to %SystemDrive%\inetpub\logs\logfile using remote computer environment variable" -BackgroundColor Yellow -ForegroundColor Blue
            $Expression = "Invoke-command -ComputerName $Computer -ScriptBlock {`$DefaultIISFolder=`"`$([Environment]::GetEnvironmentVariable(`"SystemDrive`"))\inetpub\logs\LogFile`";Set-WebConfigurationProperty `"/system.applicationHost/sites/siteDefaults`" -name logfile.directory -value `$DefaultIISFolder}"
        } Else {
            $LogDir = $NewLogLocation
            Write-Host "Changing IIS Logpath of server $Computer to $logdir" -BackgroundColor Yellow -ForegroundColor Blue
            #Putting the whole expression into a string variable to invoke it later. Reason: the variable used $LogDir will be valid only inside the -ScriptBlock, and cannot be set before.
            # Workaround is to save the whole command line into a string variable, and any variable within the string variable will be replaced with the value we want before invoke-command is even executed.
            # example: $Logdir is set earlier in the script, and will be replaced by its value within the "$Expression" string variable before even being executed.
            $Expression = "Invoke-command -ComputerName $Computer -ScriptBlock {Set-WebConfigurationProperty `"/system.applicationHost/sites/siteDefaults`" -name logfile.directory -value $Logdir}"
        }
        Write-Host "Executing the following command:" -ForegroundColor Green
        Write-Host $Expression
        Invoke-Expression $Expression
        Write-Host "Double-check the remote servers IIS log location have been changed using $($MyInvocation.MyCommand.Name) -GetIIS -Computers $Computers" -ForegroundColor Cyan
    }
} ElseIf ($GetIIS){
    ForEach ($Computer in $Computers){
        Write-Host "Checking IIS Logpath of server $Computer" -BackgroundColor Yellow -ForegroundColor Blue
        Invoke-command -ComputerName $Computer -ScriptBlock {get-WebConfigurationProperty -Filter "/system.applicationHost/sites/siteDefaults" -Name LogFile.Directory.Value}
     }
} 
