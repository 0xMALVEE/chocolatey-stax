# $ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Function to determine architecture and select Dart SDK URL accordingly
function Get-DartSdkUrl {
    $architecture = (Get-WmiObject -Class Win32_Processor).Architecture

    if ($architecture -eq 5) {
        # arm 
        return "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-windows-arm64-release.zip"
    } else {
        # x64
        return "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-windows-x64-release.zip"
    }
}

# Function to download and install Dart SDK
function Install-DartSDK {
    $dartSdkUrl = Get-DartSdkUrl
    $dartSdkPath = "$toolsDir\Dart"
    # Dart\dart-sdk\bin

    # Create temporary directory for Dart SDK
    if (!(Test-Path $dartSdkPath)) {
        New-Item -ItemType Directory -Path $dartSdkPath | Out-Null
    }

    # Download Dart SDK
    Write-Host "Downloading Dart SDK..."
    $dartZipFile = "$dartSdkPath\dartsdk.zip"
    Invoke-WebRequest -Uri $dartSdkUrl -OutFile $dartZipFile 

    # Extract Dart SDK
    Write-Host "Extracting Dart SDK..."
    Expand-Archive -Path $dartZipFile -DestinationPath $dartSdkPath
}

# Function to clone and build Stax App
function Build-DartApp {
    $appRepoUrl = "https://github.com/TarasMazepa/stax/archive/master.zip"
    $appFolder = "$toolsDir\staxcli"
    $dartSdkPath = "$toolsDir\Dart"
    $repoZipFile = "$toolsDir\staxcli\repo.zip"

    # Create temporary directory for Dart SDK
    if (!(Test-Path $appFolder)) {
        New-Item -ItemType Directory -Path $appFolder | Out-Null
    }

    # Clone App Repository
    Write-Host "Cloning Stax App repository..."
    Invoke-WebRequest -Uri $appRepoUrl -OutFile $repoZipFile

    # Extract
    Write-Host "Extracting repo.."
    Expand-Archive -Path $repoZipFile -DestinationPath $appFolder

    # Navigate to App Folder
    Set-Location "$appFolder\stax-main\cli"

    # Build Dart App
    Write-Host "Building Stax App..."
    & "$toolsDir\Dart\dart-sdk\bin\dart" pub get
    & "$toolsDir\Dart\dart-sdk\bin\dart" compile exe bin/cli.dart -o stax

    # Move binary to user folder
    $userStaxFolder = "$toolsDir\bin"
    if (!(Test-Path $userStaxFolder)) {
        New-Item -ItemType Directory -Path $userStaxFolder | Out-Null
    }
    Move-Item -Path "$appFolder\stax-main\cli\stax" -Destination $userStaxFolder -Force

    # Add binary to PATH
    $env:Path += ";$userStaxFolder"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)

}

# remove temp downloads/folders 
function Cleanup-Files { 
    $appFolder = "$toolsDir\staxcli"
    $dartSdkPath = "$toolsDir\Dart"

    Set-Location $toolsDir
    # Cleanup
    Remove-Item $appFolder -Recurse -Force
    Remove-Item $dartSdkPath -Recurse -Force
}

# Main Script

# Install Dart SDK - Temporary for building stax
Install-DartSDK

# Build Stax 
Build-DartApp

# Cleanup files 
Cleanup-Files

Write-Host "Stax installation completed."
