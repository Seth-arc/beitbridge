Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$htmlPath = Join-Path $repoRoot 'index.html'

if (-not (Test-Path -LiteralPath $htmlPath)) {
    throw "Missing index.html at $htmlPath"
}

$html = Get-Content -Raw -LiteralPath $htmlPath
$failures = New-Object System.Collections.Generic.List[string]

function Require-Match {
    param(
        [string]$Pattern,
        [string]$Message
    )

    if ($html -notmatch $Pattern) {
        $failures.Add($Message)
    }
}

Require-Match '<a class="skip-link" href="#main-content">' 'Skip link is missing.'
Require-Match 'id="story-live" class="sr-only" aria-live="polite" aria-atomic="true"' 'Live region for scene announcements is missing.'
Require-Match ':focus-visible' 'Visible focus styles are missing.'
Require-Match '@media \(prefers-reduced-motion: reduce\)' 'Reduced-motion support is missing.'
Require-Match 'data-action="choose"' 'Choice buttons are not wired through delegated actions.'
Require-Match 'data-page-heading tabindex="-1"' 'Dynamic headings are not programmatically focusable.'
Require-Match 'function handleStageAction' 'Delegated action handler is missing.'
Require-Match 'if \(cost > S\.money\) return;' 'Choice cost guard is missing.'
Require-Match "disabled aria-disabled=""true""" 'Locked choices are not marked as disabled.'

if ($html -match 'onclick=') {
    $failures.Add('Inline onclick handlers are still present.')
}

$requiredAssets = @(
    'img\letter_envelope.jpg',
    'img\stencilled_crates.jpg',
    'img\queue.jpg',
    'img\broker_intro.jpg',
    'img\broker_paid.jpg',
    'img\sars.jpg',
    'img\cert_impossible.jpg',
    'img\madziva_list.jpg',
    'img\proper_cross.jpg',
    'img\holding_room.jpg',
    'img\river.jpg',
    'img\lie.jpg',
    'img\storage_no.jpg',
    'img\musina_late.jpg',
    'img\end_screens.jpg',
    'img\kitchen_survived.jpg',
    'img\letter_lost.jpg'
)

foreach ($asset in $requiredAssets) {
    $assetPath = Join-Path $repoRoot $asset
    if (-not (Test-Path -LiteralPath $assetPath)) {
        $failures.Add("Missing required asset: $asset")
    }
}

if ($failures.Count -gt 0) {
    $message = ($failures | ForEach-Object { "- $_" }) -join [Environment]::NewLine
    throw "Production contract failed:`n$message"
}

Write-Host 'Production contract passed.'
