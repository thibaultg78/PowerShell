################################################################################################
# Version: 0.7 - 22/02/2016
# Author : Thibault Gibard - thibault.gibard@avanade.com
################################################################################################
# Obectives : 
# The objective of this script is to be called by orchestrator to launch MIM MA.
#
# - Write-Everywhere - Parameters : $MESSAGE : this function is used by every others functions 
# in order to output the script execution in the console and in a dedicated log file that will 
# be created in the same directory that the PowerShell script.
#
# - Check-IfMAisRunning - Parameters : None : this function shouldn't be call. It's used 
# only by others functions in order to check before trying to launch any Management Agent that 
# there is no MA that is already runnig or stopping. It's important to launch only 1 profile 
# execution at one time.
#
# - Launch-ManagementAgent - Parameters : $AskedManagementAgent, $Profile : this is the main
# function that will pre-check and launch the Management Agent with Profile that has been
# required.
#
# - LaunchScenario - Parameters : $Scenario : this is the main function that will be used.
# This function will launch one of the 2 scenarios that have been identified for project :
#         1- weekly : run a FULL_IMPORT + FULL_SYNC + EXPORT for all MA
#         2- daily : run a DELTA_IMPORT + DELTA_SYNC + EXPORT for all MA
# Function should be called as following : .\LaunchScneario -Scenario "weekly" 
# or .\LaunchScneario -Scenario "daily"
#
# - CleanUpMimHistory - Parameters : None : This function can be used anytime. It should be called
# one time by 3-months (90 days). This will allow to keep logs for the previous runs but will
# clean up the too much logs on the server. The duration is configured to be 90 months. If you
# need to change this setting, please edit the XML file.
################################################################################################

#cls # for cleaning the console if executed manually

################################################################################################
# Global Variables
################################################################################################
#$MIMMAList = get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $MIMComputer | where {$_.Type -eq 'Active Directory'}
$MIMHistory = get-wmiobject -Class 'MIIS_RunHistory' -namespace “root\MicrosoftIdentityIntegrationServer”
$MIMComputer = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$ProfilesAllowed = @("FULL_IMPORT","FULL_SYNC","DELTA_IMPORT","DELTA_SYNC","EXPORT")
# XML File
[xml]$XmlDocument = Get-Content -Path "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\Extensions\MIM_Custom_Configuration.xml"
$XMLManagementsAgents = $XmlDocument.'MIM'.'management-agents'.ChildNodes
################################################################################################

################################################################################################
# - Write-Everywhere - Parameters : $MESSAGE : this function is used by every others functions 
# in order to output the script execution in the console and in a dedicated log file that will 
# be created in the same directory that the PowerShell script.
################################################################################################
# Function that will generate a log file for debug use (and outputs in the console)
# $WriteFile & $WriteHost variables can be customized if needed
################################################################################################

[bool]$WriteFile = $true # You can switch this to $false if you don't want to output in the log file
[bool]$WriteHost = $true # You can switch this to $false if you don't want to ouput in the console

function Write-Everywhere ()
{
    param ($Message)   
    
    $timestamp = get-date -uformat "%Y%m%d-%T"
    $Message = $timestamp + " - " + "[LOG]" + " - " + $Message 

    # Host + File
    if ($WriteFile -eq $true -and $WriteHost -eq $true)
    {
        Write-Host $Message
        $Message | Out-File LogExecutionScript.log -Append
    }

    elseif ($WriteFile -eq $true -and $WriteHost -eq $false) 
    {
        $Message | Out-File LogExecutionScript.log -Append
    }

    elseif ($WriteFile -eq $false -and $WriteHost -eq $true) 
    {
        Write-Host $Message
    }

    elseif ($WriteFile -eq $false -and $WriteHost -eq $false) 
    {
        Write-Host "Not Output option selectioned"
    }

    else
    {
        throw Write-Host "Error Function Write-Everywhere - Impossible to output in Host or File"
    }
}

################################################################################################
# - Check-IfMAisRunning - Parameters : None - It's used 
# only by others functions in order to check before trying to launch any Management Agent that 
# there is no MA that is already runnig or stopping. It's important to launch only 1 profile 
# execution at one time.
################################################################################################
# The 2 following status will be checked :
# - running (a MA is currently running)
# - stopping (a MA is currently stopping/ending actions)
# In this 2 cases, we won't start any action on the MIM server.
################################################################################################

function Check-IfMAisRunning ()
{
    $MIMHistory = get-wmiobject -Class 'MIIS_RunHistory' -namespace “root\MicrosoftIdentityIntegrationServer”
    [bool]$MaRunning = $false
    
    foreach ($object in $MIMHistory)
    {
        if ($object.RunStatus -eq "in-progress" -or $object.RunStatus -eq "stopping" ) 
        {
            $MaRunning = $true
            Break
        }
    }
    return $MaRunning
}

################################################################################################
# - Launch-ManagementAgent - Parameters : $AskedManagementAgent, $Profile : this is the main
# function that will pre-check and launch the Management Agent with Profile that has been
# required (or just for debug purposes if needed)
################################################################################################
# Examples of calls :
#
# $return = Launch-ManagementAgent -AskedManagementAgent "BZ1 ADMA" -Profile "FULL_IMPORT"
# $return
#
# $return = Launch-ManagementAgent -AskedManagementAgent "BZ2 ADMA" -Profile "DELTA_SYNC"
# $return
################################################################################################

function Launch-ManagementAgent ()
{
    param(
    [parameter(mandatory=$true)]
    [string]$AskedManagementAgent,
    
    [parameter(mandatory=$true)]
    [string]$Profile
    )

    # Check if no MA is currently running - Otherwise, we break
    $isMARunning = Check-IfMAisRunning
    if ($isMARunning -eq $true)
    {
        Write-Everywhere "[ERROR] - One MA is currently running - Please wait every MA are stopped before trying to launch another - Exiting"
        Break
    }
    
    # Check if the Profil requested exist - Otherwise, we break
    $isThisProfileExist = $ProfilesAllowed.Contains($Profile)
    if ($isThisProfileExist -ne $true) 
    {
        Write-Everywhere "[ERROR] - Only the following Profiles are supported : FULL_IMPORT, FULL_SYNC, DELTA_IMPORT, DELTA_SYNC, EXPORT"
        Break
    }

    # Getting the object MA requested
    $MA = get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $MIMComputer | where { $_.Type -eq 'Active Directory' -and $_.Name -eq $AskedManagementAgent }

    # Check if Management Agent exist
    if (!$MA)
    {
        Write-Everywhere "[ERROR] - The Management Agent you request does not exist in MIM ! - Exiting"
        Break
    }

    # Check if XML File allow the execution of Management Agent
    $XMLFile = $XMLManagementsAgents | where { $_.name -eq $AskedManagementAgent }


    # Check if Scheduling is allowed for the Management Agent
    if ($XMLFile.SchedulingEnabled -eq "false")
    {
        Write-Everywhere ("[ERROR] - Executing profile : " + $Profile + " for " + $MA.Name + " is not permitted - Please check XML File")
        Break
    }

    # If all the previous requirements are respected and the script hasn't been break
    # We can lauch our Management Agent with requested Profile
    
    try
    {
        Write-Everywhere ("[DEBUG] - " + $Profile + " allowed for : " + $MA.Name)
        # Launching the Management Agent with the Action Required
        $dateStart = date
        Write-Everywhere ("[DEBUG] - Starting " + $Profile + " for : " + $MA.Name)
        $tempResult = $MA.Execute($Profile) # Execute Management Agent with Requested Profile Type
        $dateEnd = date
        $duration = $dateEnd - $dateStart # Get the duration
        Write-Everywhere ("[DEBUG] - Ending " + $Profile + " for : " + $MA.Name + " - Status : " + $tempResult.ReturnValue  + " - Duration : " + $Duration)
    }

    catch
    {
        # Problem : displaying the Exception and Breaking the execution
        Write-Everywhere $($_.Exception.Message)
        Break
    }

    return $ExecutionResult = @{
                                'MAName' = $MA.Name
                                'Type' = $MA.Type
                                'ReturnValue' = $tempResult.ReturnValue;
                                'Profile' = $Profile;
                                'dateStart' = $dateStart;
                                'dateEnd' = $dateEnd; 
                                'Duration' = $duration;
                                }
}

################################################################################################
# - LaunchScenario - Parameters : $Scenario : this is the main function.
# This function will launch one of the 2 scenarios that have been identified for project :
#         1- weekly : run a FULL_IMPORT + FULL_SYNC + EXPORT for all MA
#         2- daily : run a DELTA_IMPORT + DELTA_SYNC + EXPORT for all MA
# Function should be called as following : .\LaunchScneario -Scenario "weekly" 
# or .\LaunchScneario -Scenario "daily"
################################################################################################
#         1- weekly : run a FULL_IMPORT + FULL_SYNC + EXPORT for all MA
#         2- daily : run a DELTA_IMPORT + DELTA_SYNC + EXPORT for all MA
################################################################################################
# Examples of calls :
#
# $return = LaunchScenario -Scenario daily
# $return
#
# $return = LaunchScenario -Scenario weekly
# $return
################################################################################################

function LaunchScenario ()
{
    param(    
    [parameter(mandatory=$true)]
    [string]$Scenario
    )

    $AllMA = $XMLManagementsAgents
    $results = @()

    switch ($Scenario)
    {
        'weekly'
        {
            Write-Everywhere "[DEBUG] - Lauching Weekly scenario - composed of : FULL_IMPORT + FULL_SYNC + EXPORT"

            # Full_Import for all MA
            foreach ($ma in $AllMA)
            {
                Launch-ManagementAgent -AskedManagementAgent $ma.name -Profile "FULL_IMPORT"
            }

            # Full_Sync for all MA
            foreach ($ma in $AllMA)
            {
                Launch-ManagementAgent -AskedManagementAgent $ma.name -Profile "FULL_SYNC"
            }

            # Export for all MA
            foreach ($ma in $AllMA)
            {
                Launch-ManagementAgent -AskedManagementAgent $ma.name -Profile "EXPORT"
            }
        }

        'daily'
        {
            Write-Everywhere "[DEBUG] - Lauching Daily scenario - composed of : DELTA_IMPORT + DELTA_SYNC + EXPORT"

            # Delta_Import for all MA
            foreach ($ma in $AllMA)
            {
                Launch-ManagementAgent -AskedManagementAgent $ma.name -Profile "DELTA_IMPORT"
            }

            # Delta_Sync for all MA
            foreach ($ma in $AllMA)
            {
                Launch-ManagementAgent -AskedManagementAgent $ma.name -Profile "DELTA_SYNC"
            }

            # Export for all MA
            foreach ($ma in $AllMA)
            {
                Launch-ManagementAgent -AskedManagementAgent $ma.name -Profile "EXPORT"
            }

        }

        Default 
        {
            Write-Everywhere "[ERROR] - The only scenarios available are : daily or weekly"
        }
    } # End of Switch
}

################################################################################################
# - CleanUpMimHistory - Parameters : None - It should be called
# one time by 3-months (90 days). This will allow to keep logs for the previous runs but will
# clean up the too much logs on the server. The duration is configured to be 90 months. If you
# need to change this setting, please edit the XML file.
################################################################################################
# Examples of calls :
#
# $return = CleanUpMimHistory
# $return
#
################################################################################################

function CleanUpMimHistory ()
{
    $computerName = "."
    $MIMHistory = Get-Wmiobject -Class 'MIIS_RunHistory' -namespace “root\MicrosoftIdentityIntegrationServer”
    $MIMServer = Get-Wmiobject -Class "MIIS_Server" -Namespace "root\MicrosoftIdentityIntegrationServer" -ComputerName $computerName -ErrorAction SilentlyContinue
    $daysBeforeHistoryPurge = $XmlDocument.MIM.'global-settings'.daysBeforeHistoryPurge
    $endingBefore = [System.DateTime]::UtcNow.AddDays(-$daysBeforeHistoryPurge).ToString("yyyy-MM-dd HH:mm:ss.fff")

	# Clear MA runs History
    try
    {
        Write-Everywhere ("[DEBUG] - Clearing FIM run history older than " + $daysBeforeHistoryPurge + " days")
        $clearRunHistory = $MIMServer.ClearRuns($endingBefore)
        Write-Everywhere ("[DEBUG] - Status of the clearing operation : " + $clearRunHistory.ReturnValue)
    }
    catch
    {
        # Problem : displaying the Exception and Breaking the execution
        Write-Everywhere $($_.Exception.Message)
        Write-Everywhere ("[ERROR] - Problem during the clear of the MIM runs history")
        Break
    }
}

################################################################################################
################################################################################################
################################################################################################
############################ DEBUG & TESTS PURPOSES ############################################
################################################################################################
################################################################################################
################################################################################################

#$test1 = Launch-ManagementAgent -AskedManagementAgent "BZ2 ADMA" -Profile "EXPORT"
#$test1

#$test2 = LaunchScenario -Scenario weekly
#$test2

#$test2 = LaunchScenario -Scenario daily
#$test2

#$test3 = CleanUpMimHistory
#$test3
