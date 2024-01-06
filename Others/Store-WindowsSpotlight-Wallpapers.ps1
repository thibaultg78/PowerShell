cls
################################################################################################
# - Write-Everywhere - Parameters : $MESSAGE : this function is used by every others functions 
# in order to output the script execution in the console and in a dedicated log file that will 
# be created in the same directory that the PowerShell script.
################################################################################################
# Function that will generate a log file for debug use (and outputs in the console)
# $WriteFile & $WriteHost variables can be customized if needed
################################################################################################
# More details on the following link : https://akril.net/recuperer-les-images-de-windows-spotlight-dans-windows-10-en-powershell/
################################################################################################
$me = $env:username
$pathLogFile = "C:\Users\$me\Dropbox\PERSO\POWERSHELL\Windows Spotlight\WindowsSpotlight_LogExecutionScript.log"
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
        $Message | Out-File $pathLogFile -Append
    }

    elseif ($WriteFile -eq $true -and $WriteHost -eq $false) 
    {
        $Message | Out-File $pathLogFile -Append
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
################################################################################################
# IMPORTANT : The below function is taken from PSImage library
# Available here : https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Image-module-caa4405a
# It hasn't been modified and will be only used for get the width and height of pictures
################################################################################################
################################################################################################
function Get-Image {
    <#
        .Synopsis
            Returns an image object for a file
        .Description
            Uses the Windows Image Acquisition COM object to get image data
        .Example
            Get-ChildItem $env:UserProfile\Pictures -Recurse | Get-Image        
        .Parameter file
            The file to get an image from
    #>
    param(    
    [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [Alias('FullName',"FileName")]
    [ValidateScript({Test-path $_ })][string]$Path)
    
    process {
        foreach ($file in (resolve-path -Path $path) ) {
            $image  = New-Object -ComObject Wia.ImageFile        
            try {        
                Write-Verbose "Loading file $($realItem.FullName)"
                $image.LoadFile($file.path)
                $image | 
                    Add-Member NoteProperty FullName $File -PassThru | 
                    Add-Member ScriptMethod Resize {
                        param($width, $height, [switch]$DoNotPreserveAspectRatio)                    
                        $image = New-Object -ComObject Wia.ImageFile
                        $image.LoadFile($this.FullName)
                        $filter = Add-ScaleFilter @psBoundParameters -passThru -image $image
                        $image = $image | Set-ImageFilter -filter $filter -passThru
                        Remove-Item $this.Fullname
                        $image.SaveFile($this.FullName)                    
                    } -PassThru | 
                    Add-Member ScriptMethod Crop {
                        param([Double]$left, [Double]$top, [Double]$right, [Double]$bottom)
                        $image = New-Object -ComObject Wia.ImageFile
                        $image.LoadFile($this.FullName)
                        $filter = Add-CropFilter @psBoundParameters -passThru -image $image
                        $image = $image | Set-ImageFilter -filter $filter -passThru
                        Remove-Item $this.Fullname
                        $image.SaveFile($this.FullName)                    
                    } -PassThru | 
                    Add-Member ScriptMethod FlipVertical {
                        $image = New-Object -ComObject Wia.ImageFile
                        $image.LoadFile($this.FullName)
                        $filter = Add-RotateFlipFilter -flipVertical -passThru 
                        $image = $image | Set-ImageFilter -filter $filter -passThru
                        Remove-Item $this.Fullname
                        $image.SaveFile($this.FullName)                    
                    } -PassThru | 
                    Add-Member ScriptMethod FlipHorizontal {
                        $image = New-Object -ComObject Wia.ImageFile
                        $image.LoadFile($this.FullName)
                        $filter = Add-RotateFlipFilter -flipHorizontal -passThru 
                        $image = $image | Set-ImageFilter -filter $filter -passThru
                        Remove-Item $this.Fullname
                        $image.SaveFile($this.FullName)                    
                    } -PassThru |
                    Add-Member ScriptMethod RotateClockwise {
                        $image = New-Object -ComObject Wia.ImageFile
                        $image.LoadFile($this.FullName)
                        $filter = Add-RotateFlipFilter -angle 90 -passThru 
                        $image = $image | Set-ImageFilter -filter $filter -passThru
                        Remove-Item $this.Fullname
                        $image.SaveFile($this.FullName)                    
                    } -PassThru |
                    Add-Member ScriptMethod RotateCounterClockwise {
                        $image = New-Object -ComObject Wia.ImageFile
                        $image.LoadFile($this.FullName)
                        $filter = Add-RotateFlipFilter -angle 270 -passThru 
                        $image = $image | Set-ImageFilter -filter $filter -passThru
                        Remove-Item $this.Fullname
                        $image.SaveFile($this.FullName)                    
                    } -PassThru 
                    
            } catch {
                Write-Verbose $_
            }
        }     
    }    
}

################################################################################################
################################################################################################
# IMPORTANT : The above function is taken from PSImage library
# Available here : https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Image-module-caa4405a
# It hasn't been modified and will be only used for get the width and height of pictures
################################################################################################
################################################################################################

################################################################################################
# - Script Execution
################################################################################################

$source = "C:\Users\$me\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
$target = "C:\Users\$me\Dropbox\PERSO\POWERSHELL\Windows Spotlight\Wallpapers_PC"
$target_phone = "C:\Users\$me\Dropbox\PERSO\POWERSHELL\Windows Spotlight\Wallpapers_Phone"

$start = date
Write-Everywhere "Starting importing Windows Spotlight wallpapers..."

# Testing if the folder Windows Spotlight Exists
if ((Test-Path $target) -eq $false)
{
    # Creating the folder if not exist
    New-Item -ItemType directory -Path "C:\Users\$me\Pictures\Windows Spotlight\"
    Write-Everywhere "Folder created : Windows Spotlight\"
}

# Get all the images
$images = Get-ChildItem $source


# For each image
foreach ($wallpaper in $images)
{
    # If the file has NOT been already imported by previous script execution
    # We will : import copy it, then rename it by adding the jpg and log
    if ((Test-Path $target\$wallpaper.jpg) -eq $false)
    {
        # Copy
        Copy-Item $source\$wallpaper -Destination $target
        # Rename
        Rename-Item $target\$wallpaper -NewName $target\$wallpaper.jpg
        # Log
        Write-Everywhere "$wallpaper copied and added JPG extension into $target folder !"
    }

    else 
    {
        Write-Everywhere "$wallpaper has been already imported !"
    }

    # Now, we will expurge images that are not in "paysage / landscape format"
    # Get all the Height / Width details
    $image_details = Get-Image $target\$wallpaper.jpg
    # If, Width is larger that Height therefore is landscape / paysage
    if ($image_details.Height -le $image_details.Width)
    {
        Write-Everywhere "$wallpaper is a Landscape - We keep it"
    }

    # Otherwise height is Larger than Width
    # It's for phone
    else
    {
        Write-Everywhere "$wallpaper is a Portrait - Moved for Phone usage"
        if ((Test-Path $target/$wallpaper.jpg) -eq $true) {
            Remove-Item -Path $target/$wallpaper.jpg
        }

    }

}
# Ending script execution
$end = date
$duration = $end-$start
Write-Everywhere "Import of Windows Spotlight Wallpapers Done ($duration) !"
Write-Everywhere ("Number of Available Elements : " + (Get-ChildItem $target).Count)

Start-Sleep -s 10
