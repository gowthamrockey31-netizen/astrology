Add-Type -AssemblyName System.Drawing

# Load original image
$srcPath = (Resolve-Path 'UI Images/WhatsApp Image 2026-08-26 at 1.40.05 PM.jpeg').Path
$srcBmp = [System.Drawing.Bitmap]::FromFile($srcPath)

# Bounding box: minX=222, maxX=1398, minY=126, maxY=1302
# Diameter = 1176. Center = (810, 714)
$diameter = 1176
$cropX = 222
$cropY = 126

Write-Host "Target Crop: X=$cropX, Y=$cropY, Size=$diameter x $diameter"

$destBmp = New-Object System.Drawing.Bitmap($diameter, $diameter)
$g = [System.Drawing.Graphics]::FromImage($destBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Black)

$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $diameter, $diameter)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $diameter, $diameter)

$g.DrawImage($srcBmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$g.Dispose()
$srcBmp.Dispose()

# Overwrite app_logo.jpeg and save app_logo_centered.jpeg
$destBmp.Save('assets/images/app_logo.jpeg', [System.Drawing.Imaging.ImageFormat]::Jpeg)
$destBmp.Dispose()
Write-Host "Overwrote assets/images/app_logo.jpeg successfully!"
