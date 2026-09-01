Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path 'assets/images/app_logo.jpeg'))
$minX = $bmp.Width
$maxX = 0
$minY = $bmp.Height
$maxY = 0

for ($y = 0; $y -lt $bmp.Height; $y += 2) {
    for ($x = 0; $x -lt $bmp.Width; $x += 2) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.R -gt 30 -or $c.G -gt 30 -or $c.B -gt 30) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
$w = $bmp.Width
$h = $bmp.Height
$bmp.Dispose()
Write-Host "Width=$w, Height=$h"
Write-Host "Bounds: minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY"
$cx = ($minX + $maxX) / 2
$cy = ($minY + $maxY) / 2
Write-Host "Center X = $cx, Center Y = $cy"
Write-Host "Diameter X = $($maxX - $minX), Diameter Y = $($maxY - $minY)"
Write-Host "Offset from image center: dX = $($cx - ($w/2)), dY = $($cy - ($h/2))"
