# Define the directories and files to remove
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$staxBinaryFolder = "$toolsDir\bin"

# Function to uninstall stax
function Uninstall-DartApp {
    Write-Host "Uninstalling Stax..."

    # Remove Dart CLI binary and its parent folder
    Remove-Item -Path "$staxBinaryFolder\stax" -Force
    Remove-Item -Path $staxBinaryFolder -Force

    # Remove the directory from the user-level PATH
    [Environment]::SetEnvironmentVariable("Path", $env:Path -replace [regex]::Escape("$staxBinaryFolder;"), "User")
}

# Main Script
# Uninstall stax
Uninstall-DartApp

Write-Host "Stax uninstallation completed."
