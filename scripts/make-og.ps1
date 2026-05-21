# Generates images/og.png (1200x630) — branded Open Graph / Twitter share card.
# Run: powershell -ExecutionPolicy Bypass -File scripts\make-og.ps1
Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Background: white
$g.Clear([System.Drawing.Color]::FromArgb(255, 255, 255))

# Top accent band (navy)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))), 0, 0, $W, 14)

# Brand orb (gradient circle)
$orb = New-Object System.Drawing.Rectangle(80, 86, 64, 64)
$orbBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($orb, [System.Drawing.Color]::FromArgb(47, 91, 224), [System.Drawing.Color]::FromArgb(30, 58, 138), 45)
$g.FillEllipse($orbBrush, $orb)

# Fonts
$fName = New-Object System.Drawing.Font("Segoe UI Semibold", 60, [System.Drawing.FontStyle]::Bold)
$fSub  = New-Object System.Drawing.Font("Segoe UI", 32, [System.Drawing.FontStyle]::Regular)
$fLine = New-Object System.Drawing.Font("Segoe UI", 25, [System.Drawing.FontStyle]::Regular)
$fUrl  = New-Object System.Drawing.Font("Consolas", 22, [System.Drawing.FontStyle]::Regular)

# Brushes
$ink  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22, 23, 28))
$blue = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 64, 175))
$gray = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(91, 93, 104))

$g.DrawString("Keystone Marcy", $fName, $ink, 76, 200)
$g.DrawString("FP&A & Strategic Finance Leader", $fSub, $blue, 80, 300)
$g.DrawString("Apps, AI workflows & Excel/ERP tooling for finance teams", $fLine, $gray, 80, 358)
$g.DrawString("keystonemarcy.netlify.app", $fUrl, $gray, 80, 520)

$out = Join-Path $PSScriptRoot "..\images\og.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output ("Wrote " + (Resolve-Path $out))
