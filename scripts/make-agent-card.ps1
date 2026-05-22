# Generates images/proj-agent.png (1440x900) — a branded "Agent Dashboard" observability
# mock card for the Work section, in the site's light/navy palette.
# Run: powershell -ExecutionPolicy Bypass -File scripts\make-agent-card.ps1
Add-Type -AssemblyName System.Drawing

$W = 1440; $H = 900
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Palette
$white  = [System.Drawing.Color]::FromArgb(255,255,255)
$surf2  = [System.Drawing.Color]::FromArgb(243,244,247)
$border = [System.Drawing.Color]::FromArgb(214,216,220)
$ink    = [System.Drawing.Color]::FromArgb(22,23,28)
$dim    = [System.Drawing.Color]::FromArgb(68,70,79)
$muted  = [System.Drawing.Color]::FromArgb(91,93,104)
$nav1   = [System.Drawing.Color]::FromArgb(39,71,201)
$nav2   = [System.Drawing.Color]::FromArgb(30,58,138)

$g.Clear($white)

# Top accent band
$g.FillRectangle((New-Object System.Drawing.SolidBrush($nav1)), 0, 0, $W, 14)

# Helper: rounded rectangle path
function New-RoundRect([int]$x,[int]$y,[int]$w,[int]$h,[int]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

# Brushes / pens / fonts
$bInk   = New-Object System.Drawing.SolidBrush($ink)
$bDim   = New-Object System.Drawing.SolidBrush($dim)
$bMuted = New-Object System.Drawing.SolidBrush($muted)
$bNav   = New-Object System.Drawing.SolidBrush($nav2)
$bSurf  = New-Object System.Drawing.SolidBrush($surf2)
$pBorder = New-Object System.Drawing.Pen($border, 1.5)

$fTitle = New-Object System.Drawing.Font("Segoe UI Semibold", 44, [System.Drawing.FontStyle]::Bold)
$fSub   = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Regular)
$fNum   = New-Object System.Drawing.Font("Segoe UI Semibold", 52, [System.Drawing.FontStyle]::Bold)
$fLabel = New-Object System.Drawing.Font("Consolas", 15, [System.Drawing.FontStyle]::Regular)
$fRow   = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Regular)

# Header
$g.DrawString("Agent Dashboard", $fTitle, $bInk, 60, 60)
$g.DrawString("Agentic OS  -  workflow, skill & token observability", $fSub, $bMuted, 64, 138)

# Metric tiles
$tiles = @(
    @{ n = "12";   l = "ACTIVE WORKFLOWS" },
    @{ n = "47";   l = "SKILLS INVOKED" },
    @{ n = "1.2M"; l = "TOKENS TRACKED" },
    @{ n = "98%";  l = "TASK SUCCESS" }
)
$tx = 60; $ty = 220; $tw = 312; $th = 196; $gap = 28
foreach ($t in $tiles) {
    $rr = New-RoundRect $tx $ty $tw $th 18
    $g.FillPath($bSurf, $rr)
    $g.DrawPath($pBorder, $rr)
    $g.DrawString($t.n, $fNum, $bNav, ($tx + 26), ($ty + 40))
    $g.DrawString($t.l, $fLabel, $bMuted, ($tx + 28), ($ty + 130))
    $tx += $tw + $gap
}

# "Recent runs" panel
$py = 452; $pw = $W - 120; $ph = 392
$panel = New-RoundRect 60 $py $pw $ph 18
$g.FillPath($bSurf, $panel)
$g.DrawPath($pBorder, $panel)
$g.DrawString("Recent agent runs", (New-Object System.Drawing.Font("Segoe UI Semibold", 20, [System.Drawing.FontStyle]::Bold)), $bDim, 90, ($py + 24))

# Mock run rows
$rows = @(
    "Forecast variance summary       . . . . . . .  done",
    "Month-end close checklist       . . . . . . .  done",
    "Recruiter reply triage          . . . . . . .  running",
    "Resume tailoring (3 roles)      . . . . . . .  done",
    "ERP data-migration validation   . . . . . . .  done"
)
$ry = $py + 84
foreach ($r in $rows) {
    # row background bar
    $rowRect = New-RoundRect 90 $ry ($pw - 60) 44 10
    $g.FillPath((New-Object System.Drawing.SolidBrush($white)), $rowRect)
    $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230,231,236), 1)), $rowRect)
    # status dot
    $g.FillEllipse($bNav, 108, ($ry + 16), 12, 12)
    $g.DrawString($r, $fRow, $bDim, 138, ($ry + 9))
    $ry += 58
}

$out = Join-Path $PSScriptRoot "..\images\proj-agent.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output ("Wrote " + (Resolve-Path $out))
