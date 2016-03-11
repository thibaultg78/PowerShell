#===============================================================================
# Script information
#===============================================================================
# NAME: Create-DB-Site-XD7
# VERSION: 1.0
# DESCRIPTION: Script permettant de creer les DB XenDesktop 7.1 et le Site XenDesktop 7.1
#-------------------------------------------------------------------------------
 
function Write-Log() {
    # Parameters : message, type of message (info, warning, error), logfile
    param($Message,$status)
    
    # Timestamp : for better reading of log files
    $timestamp = get-date -uformat "%Y%m%d-%T"
    Write-Host "$timestamp " -NoNewline

    switch($status) {

    "OK" { 
        Write-Host -ForegroundColor Green "[OK] " -NoNewline
		Add-Content $LogFile "$timestamp [OK] $Message"
        }
    "INFO" { 
        Write-Host -ForegroundColor Yellow "[INFO] " -NoNewline
		Add-Content $LogFile "$timestamp [INFO] $Message"
        } 
    "ERROR" { 
        Write-Host -ForegroundColor Red "[ERROR] " -NoNewline
		Add-Content $LogFile "$timestamp [ERROR] $Message"
        } 
	default { 
        Write-Host -ForegroundColor Gray "[$Status] " -NoNewline
		Add-Content $LogFile "$timestamp [$Status] $Message"
        }
	}
    
	Write-Host $Message
}

#===============================================================================
# Script Configuration
#===============================================================================
Set-PSDebug -strict
#-------------------------------------------------------------------------------
# Global variables and const
#-------------------------------------------------------------------------------
$ErrorActionPreference = "Stop"  # Le script stoppera a la moindre erreur
$LogOK = "OK"
$LogInfo = "INFO"
$LogError = "ERROR"
# Recupere emplacement script, fichier log et fichier configuration XML
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$LogFile = $PSScriptRoot + "\" + ($MyInvocation.MyCommand).Name.Replace(".ps1", ".log")
$ConfigFile = $PSScriptRoot + "\" + ($MyInvocation.MyCommand).Name.Replace(".ps1", ".xml")

#-------------------------------------------------------------------------------
# Start error trapping
#-------------------------------------------------------------------------------
trap [Exception] { Write-Log $($_.Exception.GetType().FullName + " - " + $_.Exception.Message) $LogError; continue}

#-------------------------------------------------------------------------------
# Load configuration from the config file
#-------------------------------------------------------------------------------
[XML]$config = Get-Content $ConfigFile # Chargement du fichier de configuration XML

$DatabaseServer = Select-Xml $config -XPath "/configuration/Database_Configuration/DatabaseServer"
$DatabaseName_Site = Select-Xml $config -XPath "/configuration/Database_Configuration/DatabaseName_Site"
$DatabaseName_Logging = Select-Xml $config -XPath "/configuration/Database_Configuration/DatabaseName_Logging"
$DatabaseName_Monitor = Select-Xml $config -XPath "/configuration/Database_Configuration/DatabaseName_Monitor"

$DatabaseUser = Select-Xml $config -XPath "/configuration/Database_Configuration/DatabaseUser"
$DatabasePassword = Select-Xml $config -XPath "/configuration/Database_Configuration/DatabasePassword"

$XD7Site = Select-Xml $config -XPath "/configuration/Site_Configuration/XD7Site"
$FullAdminGroup = Select-Xml $config -XPath "/configuration/Site_Configuration/FullAdminGroup"
$ROAdminGroup = Select-Xml $config -XPath "/configuration/Site_Configuration/ROAdminGroup"
$HelpDeskGroup = Select-Xml $config -XPath "/configuration/Site_Configuration/HelpDeskGroup"

#===============================================================================
# Script body
#===============================================================================

# Confirmation de la configuration
Write-Host "Rappel de la configuration choisie dans fichier XML :"
Write-Host "- Serveur DB :" $DatabaseServer
Write-Host "- DB Site XA7 :" $DatabaseName_Site
Write-Host "- DB Log XA7 :" $DatabaseName_Logging
Write-Host "- DB Mon XA7 :" $DatabaseName_Monitor 
Write-Host "- DB User :" $DatabaseUser 
Write-Host "- DB Password :" $DatabasePassword
Write-Host "- Site XenApp 7 :" $XD7Site
Write-Host "- Groupe Full Admin du site :" $FullAdminGroup
Write-Host "- Groupe Read Only du site :" $ROAdminGroup
Write-Host "- Groupe HelpDesk du site :" $HelpDeskGroup

# Import module Citrix et chargement des CmdLets
Write-Log "Import du module et chargement des CmdLets Citrix.* en cours..." $LogInfo
Import-Module Citrix.XenDesktop.Admin
Add-PSSnapin Citrix.*
Write-Log "Import termine." $LogOK

# Connexion au serveur SQL et creation des bases de donnees
$DatabasePassword = $DatabasePassword | ConvertTo-SecureString -asPlainText -Force
$Database_CredObject = New-Object System.Management.Automation.PSCredential($DatabaseUser,$DatabasePassword)
Write-Log "Identifiants OK - Tentative de creation des bases de donnees..." $LogInfo

New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XD7Site -DataStore Site -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Site -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XD7Site -DataStore Logging -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Logging -DatabaseCredentials $Database_CredObject 
New-XDDatabase -AdminAddress $env:COMPUTERNAME -SiteName $XD7Site -DataStore Monitor -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName_Monitor -DatabaseCredentials $Database_CredObject 
Write-Log "Bases de donnees creees avec succes." $LogOK

# Creation Site XenApp 7 (ferme applicative dans XenApp)
Write-Log "Site XenApp 7 en cours de creation..." $LogInfo
New-XDSite -DatabaseServer $DatabaseServer -LoggingDatabaseName $DatabaseName_Logging -MonitorDatabaseName $DatabaseName_Monitor -SiteDatabaseName $DatabaseName_Site -SiteName $XD7Site -AdminAddress $env:COMPUTERNAME
Write-Log "Site XenApp 7 cree avec succes." $LogOK

# Ajout d'un groupe AD en tant que Full Administrator du Site XenApp 7
Write-Log "Ajout du groupe comme Full Administrateur du site XenApp 7." $LogInfo
New-AdminAdministrator -AdminAddress $env:COMPUTERNAME -Name $FullAdminGroup
Add-AdminRight -AdminAddress $env:COMPUTERNAME -Administrator $FullAdminGroup -Role 'Full Administrator' -All
Write-Log "Groupe Administrateur definit avec succes." $LogOK

# Ajout d'un groupe AD en tant que Read Only Admin du Site XenApp 7
Write-Log "Ajout du groupe comme Read-Only Admin du site XenApp 7." $LogInfo
New-AdminAdministrator -AdminAddress $env:COMPUTERNAME -Name $ROAdminGroup
Add-AdminRight -AdminAddress $env:COMPUTERNAME -Administrator $ROAdminGroup -Role 'Read Only Administrator' -All
Write-Log "Groupe Read Only Admin definit avec succes." $LogOK

# Ajout d'un groupe AD en tant que HelpDesk du Site XenApp 7
Write-Log "Ajout du groupe comme HelpDesk du site XenApp 7." $LogInfo
New-AdminAdministrator -AdminAddress $env:COMPUTERNAME -Name $HelpDeskGroup
Add-AdminRight -AdminAddress $env:COMPUTERNAME -Administrator $HelpDeskGroup -Role 'Help Desk Administrator' -All
Write-Log "Groupe Help Desk definit avec succes." $LogOK

# Fin programme
Write-Log "EOP - Fin du programme - Pressez une touche pour terminer." $LogOK
Read-Host

