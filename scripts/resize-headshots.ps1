# Resize the two source headshots into web-ready 1024x1024 progressive JPEGs.
# Reads PNG originals from the user's local headshot library (outside this repo)
# and writes into images/ inside this repo. Idempotent.

Add-Type -AssemblyName System.Drawing

$SourceDir = 'C:\Users\keyst\headshots\linkedin'
$RepoRoot  = Split-Path -Parent $PSScriptRoot
$OutDir    = Join-Path $RepoRoot 'images'

$Jobs = @(
    @{
        Source = Join-Path $SourceDir '7ebe20d5-8480-4d66-be5e-52cdc04542e7.png'
        Dest   = Join-Path $OutDir 'headshot-hero.jpg'
    },
    @{
        Source = Join-Path $SourceDir '87214a06-e06e-41c7-9b28-500308fbe1d2.png'
        Dest   = Join-Path $OutDir 'headshot-about.jpg'
    }
)

function Convert-ToWebJpeg {
    param([string]$Source, [string]$Dest, [int]$Size = 1024, [int]$Quality = 82)

    if (-not (Test-Path $Source)) {
        Write-Error "Source missing: $Source"
        return
    }

    $img = [System.Drawing.Image]::FromFile($Source)
    try {
        $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
        try {
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $g.DrawImage($img, 0, 0, $Size, $Size)
            $g.Dispose()

            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
                Where-Object { $_.MimeType -eq 'image/jpeg' }
            $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
                [System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)

            $bmp.Save($Dest, $jpegCodec, $params)
            $kb = [math]::Round((Get-Item $Dest).Length / 1KB, 1)
            Write-Host "[ok] $([System.IO.Path]::GetFileName($Dest))  $kb KB"
        } finally {
            $bmp.Dispose()
        }
    } finally {
        $img.Dispose()
    }
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

foreach ($job in $Jobs) {
    Convert-ToWebJpeg -Source $job.Source -Dest $job.Dest
}
