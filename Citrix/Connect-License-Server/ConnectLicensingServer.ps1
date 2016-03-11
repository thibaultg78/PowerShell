#===============================================================================
# Script information
#===============================================================================
# NAME: ConnectLicensingServer
# VERSION: 1.0
# DESCRIPTION: Connecte et configure un Delivery Controller à son serveur de licences
#-------------------------------------------------------------------------------

#===============================================================================
# Script Configuration
#===============================================================================
Set-PSDebug -strict
$ErrorActionPreference = "Stop"  # Le script stoppera a la moindre erreur

# Recupere emplacement script, fichier log et fichier configuration XML
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ConfigFile = $PSScriptRoot + "\" + ($MyInvocation.MyCommand).Name.Replace(".ps1", ".xml")

#-------------------------------------------------------------------------------
# Non nécessaire
#-------------------------------------------------------------------------------
#Write-Host "[LOG] - Import du module et chargement des CmdLets Citrix.* en cours..."
#Import-Module Citrix.XenDesktop.Admin
#Add-PSSnapin Citrix.*
#Write-Host "[LOG] - Import termine."

#-------------------------------------------------------------------------------
# Load configuration from the config file
#-------------------------------------------------------------------------------
[XML]$config = Get-Content $ConfigFile # Chargement du fichier de configuration XML

$LicenseServer = Select-Xml $config -XPath "/configuration/Lic_Config/LicenseServer"
$LicenseServer_LicensingModel = Select-Xml $config -XPath "/configuration/Lic_Config/LicenseServer_LicensingModel"
$LicenseServer_ProductCode = Select-Xml $config -XPath "/configuration/Lic_Config/LicenseServer_ProductCode"
$LicenseServer_ProductEdition = Select-Xml $config -XPath "/configuration/Lic_Config/LicenseServer_ProductEdition"

# On definit quel sera notre serveur de licence : Adresse IP du serveur de licences Citrix et Port
Set-XDLicensing -AdminAddress $env:COMPUTERNAME -LicenseServerAddress $LicenseServer -LicenseServerPort 27000

Write-Host "[LOG] - Definition du serveur de licences Citrix - OK"

# On configure notre site XenDesktop 7.1 en specifiant le modele et le niveau de licenses
Set-ConfigSite  -AdminAddress $env:COMPUTERNAME -LicensingModel $LicenseServer_LicensingModel -ProductCode $LicenseServer_ProductCode -ProductEdition $LicenseServer_ProductEdition

Write-Host "[LOG] - Configuration du mode de licences Carrefour (Enterprise et XenApp Concurrent) - OK"

# On recupere le Hash du certificat du serveur de licences
Set-ConfigSiteMetadata -AdminAddress $env:COMPUTERNAME -Name 'CertificateHash' -Value $(Get-LicCertificate -AdminAddress "https://$LicenseServer").CertHash

Write-Host "[LOG] - Recuperation du hash du certificat du serveur de licences Citrix - OK"
Write-Host "[EOP] - Fin de programme - Pressez une touche pour terminer"
Read-Host



