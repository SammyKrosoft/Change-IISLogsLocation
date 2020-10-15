[CmdletBinding(DefaultParameterSetName="GetInfo")]

param(
    [parameter(ParameterSetName="GetInfo")][switch]$GetIIS,
    [parameter(ParameterSetName="SetInfo")][switch]$SetIIS,
    [Parameter(ParameterSetName="SetInfo")][string]$NewLogLocation = "c:\IISLogsNewLocation",
    [Parameter(ParameterSetName="SetInfo")]
    [Parameter(ParameterSetName="GetInfo")]
    [string[]]$Computers = @("E2016-01", "E2016-02")


)


# Putting default location (previous one just in case) in a variable
$DefaultLogLocation = "$($env:SystemDrive)\inetpub\logs\LogFile"
# Putting new target desired location in a variable
# $NewLogLocation = "c:\IISLogsNewLocation" ==> Parameter

#Just to simplify and for the sake of using variables, putting desired Log Location variable in $LogDir variable
# If you want to change back to the default location, use $LogDir = $DefaultLogLocation

# $MyComputers = "E2016-01", "E2016-02" ==> Parameter

Import-Module WebAdministration

If ($SetIIS){
    $Logdir = $NewLogLocation

    ForEach ($Computer in $MyComputers){
        Write-Host "Changing IIS Logpath of server $Computer to $logdir" -BackgroundColor Yellow -ForegroundColor Blue
         Invoke-command -ComputerName $Computer -ScriptBlock {Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory -value $logdir}
    }
} ElseIf ($GetIIS){
    ForEach ($Computer in $MyComputers){
        Write-Host "Checking IIS Logpath of server $Computer" -BackgroundColor Yellow -ForegroundColor Blue
        Invoke-command -ComputerName $Computer -ScriptBlock {get-WebConfigurationProperty -Filter "/system.applicationHost/sites/siteDefaults" -Name LogFile.Directory.Value}
     }
} 
