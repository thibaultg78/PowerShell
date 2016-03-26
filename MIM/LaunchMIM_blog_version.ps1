cls # for cleaning the console if executed manually

################################################################################################
# Global Variables
################################################################################################
$MIMMAList = get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $MIMComputer | where {$_.Type -eq 'Active Directory'}
$MIMHistory = get-wmiobject -Class 'MIIS_RunHistory' -namespace “root\MicrosoftIdentityIntegrationServer”
$MIMComputer = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$ProfilesAllowed = @("FULL_IMPORT","FULL_SYNC","DELTA_IMPORT","DELTA_SYNC","EXPORT")

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
# required.
################################################################################################
# Examples of calls :
#
# $return = Launch-ManagementAgent -AskedManagementAgent "BZ1 ADMA" -Profile "FULL_IMPORT"
# $return
#
# $return = Launch-ManagementAgent -AskedManagementAgent "BZ2 ADMA" -Profile "DELTA_SYNC"
# $return
################################################################################################

$ProfilesAllowed = @("FULL_IMPORT","FULL_SYNC","DELTA_IMPORT","DELTA_SYNC","EXPORT")

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
        Write-Host "[ERROR] - One MA is currently running - Please wait every MA are stopped before trying to launch another - Exiting"
        Break
    }
    
    # Check if the Profil requested exist - Otherwise, we break
    $isThisProfileExist = $ProfilesAllowed.Contains($Profile)
    if ($isThisProfileExist -ne $true) 
    {
        Write-Host "[ERROR] - Only the following Profiles are supported : FULL_IMPORT, FULL_SYNC, DELTA_IMPORT, DELTA_SYNC, EXPORT"
        Break
    }

    # Getting the object MA requested
    $MA = get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $MIMComputer | where { $_.Type -eq 'Active Directory' -and $_.Name -eq $AskedManagementAgent }

    # Check if Management Agent exist
    if (!$MA)
    {
        Write-Host "[ERROR] - The Management Agent you request does not exist in MIM ! - Exiting"
        Break
    }

    # If all the previous requirements are respected and the script hasn't been break
    # We can lauch our Management Agent with requested Profile
    
    try
    {
        # Launching the Management Agent with the Action Required
        $dateStart = date
        Write-Host ("[DEBUG] - Starting " + $Profile + " for : " + $MA.Name)
        $tempResult = $MA.Execute($Profile) # Execute Management Agent with Requested Profile Type
        $dateEnd = date
        $duration = $dateEnd - $dateStart # Get the duration
        Write-Host ("[DEBUG] - Ending " + $Profile + " for : " + $MA.Name + " - Status : " + $tempResult.ReturnValue  + " - Duration : " + $Duration)
    }

    catch
    {
        # Problem : displaying the Exception and Breaking the execution
        Write-Host $($_.Exception.Message)
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
# - LaunchScenario - Parameters : $Scenario : Main function to be called.
# This function will launch one of the 2 scenarios that have been identified :
#         1- weekly : run a FULL_IMPORT + FULL_SYNC + EXPORT for all MA
#         2- daily : run a DELTA_IMPORT + DELTA_SYNC + EXPORT for all MA
# Function should be called as following : LaunchScneario -Scenario "weekly" 
# or LaunchScneario -Scenario "daily"
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

$MIMMAList = get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $MIMComputer | where {$_.Type -eq 'Active Directory'}

function LaunchScenario ()
{
    param(    
    [parameter(mandatory=$true)]
    [string]$Scenario
    )

    $AllMA = $MIMMAList
    $results = @()

    switch ($Scenario)
    {
        'weekly'
        {
            Write-Host "[DEBUG] - Lauching Weekly scenario - composed of : FULL_IMPORT + FULL_SYNC + EXPORT"

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
            Write-Host "[DEBUG] - Lauching Daily scenario - composed of : DELTA_IMPORT + DELTA_SYNC + EXPORT"

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
            Write-Host "[ERROR] - The only scenarios available are : daily or weekly"
        }
    } # End of Switch
}

################################################################################################
################################################################################################
################################################################################################
############################ EXAMPLES OF CALLS	################################################
################################################################################################
################################################################################################
################################################################################################

#$test1 = Launch-ManagementAgent -AskedManagementAgent "BZ1 ADMA" -Profile "DELTA_IMPORT"
#$test1

#$test2 = LaunchScenario -Scenario weekly
#$test2

#$test2 = LaunchScenario -Scenario daily
#$test2
