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
    [string[]]$Computers = @("E2016-01", "E2016-02")


)

Import-Module WebAdministration

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
            # example: $Logdir is set earlier in the script, and will be replaced by its value within the "$Expression" string variable.
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
