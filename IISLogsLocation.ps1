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


# Putting default location (previous one just in case) in a variable
$DefaultLogLocation = "$($env:SystemDrive)\inetpub\logs\LogFile"
# Putting new target desired location in a variable
# $NewLogLocation = "c:\IISLogsNewLocation" ==> Parameter

#Just to simplify and for the sake of using variables, putting desired Log Location variable in $LogDir variable
# If you want to change back to the default location, use $LogDir = $DefaultLogLocation

# $MyComputers = "E2016-01", "E2016-02" ==> Parameter

Import-Module WebAdministration

If ($SetIIS){
    If ($DefaultLocation){$Logdir = $DefaultLogLocation} Else {
        [string]$Logdir = $NewLogLocation
        }
    ForEach ($Computer in $Computers){
        Write-Host "Changing IIS Logpath of server $Computer to $logdir" -BackgroundColor Yellow -ForegroundColor Blue
        #Putting the whole expression into a string variable to invoke it later. Reason: the variable used $LogDir will be valid only inside the -ScriptBlock, and cannot be set before.
        # Workaround is to save the whole command line into a string variable, and any variable within the string variable will be replaced with the value we set.
        # example: $Logdir is set earlier in the script, and will be replaced by its value within the "$Expression" string variable.
        $Expression = "Invoke-command -ComputerName $Computer -ScriptBlock {Set-WebConfigurationProperty `"/system.applicationHost/sites/siteDefaults`" -name logfile.directory -value $Logdir}"
        Write-Host "Executing the following command:" -ForegroundColor Green
        Write-Host $Expression
        Invoke-Expression $Expression
    }
} ElseIf ($GetIIS){
    ForEach ($Computer in $Computers){
        Write-Host "Checking IIS Logpath of server $Computer" -BackgroundColor Yellow -ForegroundColor Blue
        Invoke-command -ComputerName $Computer -ScriptBlock {get-WebConfigurationProperty -Filter "/system.applicationHost/sites/siteDefaults" -Name LogFile.Directory.Value}
     }
} 
