$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Function to determine architecture and select Dart SDK URL accordingly
function Get-DartSdkUrl {
    $architecture = (Get-WmiObject -Class Win32_Processor).Architecture

    if ($architecture -eq 5) {
        return "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-windows-arm64-release.zip"
    } else {
        return "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-windows-x64-release.zip"
    }
}

# Function to download and install Dart SDK
function Install-DartSDK {
    $dartSdkUrl = Get-DartSdkUrl
    $dartTempDir = "$env:TEMP\DartSDK"
    $dartSdkPath = "$toolsDir\Dart"

    # Create temporary directory for Dart SDK
    if (!(Test-Path $dartTempDir)) {
        New-Item -ItemType Directory -Path $dartTempDir | Out-Null
    }

    # Download Dart SDK
    Write-Host "Downloading Dart SDK..."
    $dartZipFile = "$dartTempDir\dartsdk.zip"
    Invoke-WebRequest -Uri $dartSdkUrl -OutFile $dartZipFile

    # Extract Dart SDK
    Write-Host "Extracting Dart SDK..."
    Expand-Archive -Path $dartZipFile -DestinationPath $dartTempDir

    # Move Dart SDK to tools directory
    Move-Item -Path "$dartTempDir\dart-sdk" -Destination $dartSdkPath -Force

    # Cleanup
    Remove-Item $dartTempDir -Recurse -Force
}

# Function to clone and build Dart CLI App
function Build-DartApp {
    $appRepoUrl = "https://github.com/TarasMazepa/stax.git"
    $appFolder = "$toolsDir\dart_app"

    # Clone App Repository
    Write-Host "Cloning Dart CLI App repository..."
    git clone $appRepoUrl $appFolder

    # Navigate to App Folder
    Set-Location "$appFolder\cli"

    # Build Dart App
    Write-Host "Building Dart CLI App..."
    & "$toolsDir\Dart\bin\dart" pub get
    & "$toolsDir\Dart\bin\dart" compile exe bin/cli.dart -o stax

    # Cleanup
    Remove-Item $appFolder -Recurse -Force
}

# Main Script

# Install Dart SDK
Install-DartSDK

# Build Dart CLI App
Build-DartApp

Write-Host "Dart SDK and CLI Dart App installation completed."
