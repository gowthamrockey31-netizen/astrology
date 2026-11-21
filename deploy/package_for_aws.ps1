# PowerShell script to package AstroDashaCare deployment bundle for AWS
param (
    [string]$OutputFile = "..\astrodashacare_aws_deploy.zip"
)

Write-Host "Creating deployment bundle for AWS..." -ForegroundColor Cyan

$tempDir = Join-Path $env:TEMP "astrodashacare_deploy_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$webTarget = Join-Path $tempDir "web"
$backendTarget = Join-Path $tempDir "backend"
$downloadsTarget = Join-Path $tempDir "downloads"

# Copy Flutter Web build
Write-Host "Copying Flutter Web build..."
Copy-Item -Path "build\web" -Destination $webTarget -Recurse -Force

# Copy Backend
Write-Host "Copying Backend..."
New-Item -ItemType Directory -Path $backendTarget -Force | Out-Null
Copy-Item -Path "backend\main.py" -Destination $backendTarget -Force
Copy-Item -Path "backend\requirements.txt" -Destination $backendTarget -Force
if (Test-Path "backend\astrocall_mongodb_data.json") {
    Copy-Item -Path "backend\astrocall_mongodb_data.json" -Destination $backendTarget -Force
}

# Copy Android APK
New-Item -ItemType Directory -Path $downloadsTarget -Force | Out-Null
if (Test-Path "AstroDashaCare.apk") {
    Copy-Item -Path "AstroDashaCare.apk" -Destination (Join-Path $downloadsTarget "AstroDashaCare.apk") -Force
}

# Copy deployment configs
Copy-Item -Path "deploy\nginx.conf" -Destination $tempDir -Force
Copy-Item -Path "deploy\astrodashacare-backend.service" -Destination $backendTarget -Force
Copy-Item -Path "deploy\setup_aws_ec2.sh" -Destination $tempDir -Force

# Create ZIP
Write-Host "Compressing deployment archive to $OutputFile..."
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
}
Compress-Archive -Path "$tempDir\*" -DestinationPath $OutputFile -Force

Remove-Item -Path $tempDir -Recurse -Force
Write-Host "SUCCESS! Deployment package ready at: $OutputFile" -ForegroundColor Green

