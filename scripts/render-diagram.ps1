param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '../assets/images/ai-map.png')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$bitmap = [System.Drawing.Bitmap]::new(1000, 720)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$graphics.Clear([System.Drawing.Color]::White)
$titleFont = [System.Drawing.Font]::new('Georgia', 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$captionFont = [System.Drawing.Font]::new('Georgia', 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$textBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#25332c'))

function Add-DiagramLayer {
    param(
        [string]$Title,
        [string]$Caption,
        [int]$Left,
        [int]$Top,
        [int]$Width,
        [int]$Height,
        [string]$Color
    )
    $background = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($Color))
    $border = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#59776b'), 2)
    try {
        $graphics.FillRectangle($background, $Left, $Top, $Width, $Height)
        $graphics.DrawRectangle($border, $Left, $Top, $Width, $Height)
        $graphics.DrawString($Title, $titleFont, $textBrush, $Left + 24, $Top + 18)
        $graphics.DrawString($Caption, $captionFont, $textBrush, $Left + 24, $Top + 66)
    }
    finally {
        $background.Dispose()
        $border.Dispose()
    }
}

try {
    Add-DiagramLayer -Title 'Artificial intelligence' -Caption 'Search, planning, rules, and learned methods' -Left 24 -Top 24 -Width 952 -Height 672 -Color '#f7f8f7'
    Add-DiagramLayer -Title 'Machine learning' -Caption 'Learning from data or experience' -Left 84 -Top 156 -Width 864 -Height 512 -Color '#edf3f0'
    Add-DiagramLayer -Title 'Deep learning' -Caption 'Multiple layers of learned representations' -Left 144 -Top 288 -Width 776 -Height 352 -Color '#dcece4'
    Add-DiagramLayer -Title 'Large language models' -Caption 'Contemporary LLMs: deep neural language models' -Left 204 -Top 428 -Width 688 -Height 172 -Color '#fff0e7'
    $destination = [System.IO.Path]::GetFullPath($OutputPath)
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($destination)) | Out-Null
    $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "PASS: generated $destination ($($bitmap.Width) x $($bitmap.Height))."
}
finally {
    $textBrush.Dispose()
    $titleFont.Dispose()
    $captionFont.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}