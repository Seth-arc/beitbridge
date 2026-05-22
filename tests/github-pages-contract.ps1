Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $repoRoot '.github\workflows\deploy-pages.yml'
$noJekyllPath = Join-Path $repoRoot '.nojekyll'
$failures = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $workflowPath)) {
    $failures.Add('Missing .github/workflows/deploy-pages.yml.')
}

if (-not (Test-Path -LiteralPath $noJekyllPath)) {
    $failures.Add('Missing .nojekyll marker file.')
}

if (Test-Path -LiteralPath $workflowPath) {
    $workflow = Get-Content -Raw -LiteralPath $workflowPath

    $requiredPatterns = @(
        @{ Pattern = 'branches:\s*\r?\n\s*-\s*main'; Message = 'Workflow does not deploy from main.' },
        @{ Pattern = 'workflow_dispatch:'; Message = 'Workflow is missing manual dispatch.' },
        @{ Pattern = 'actions/checkout@v6'; Message = 'Workflow is not using the current checkout action major.' },
        @{ Pattern = 'actions/configure-pages@v5'; Message = 'Workflow is missing configure-pages.' },
        @{ Pattern = 'actions/upload-pages-artifact@v4'; Message = 'Workflow is missing upload-pages-artifact.' },
        @{ Pattern = 'actions/deploy-pages@v4'; Message = 'Workflow is missing deploy-pages.' },
        @{ Pattern = 'cp index\.html _site/index\.html'; Message = 'Workflow does not publish index.html.' },
        @{ Pattern = 'cp -R img _site/img'; Message = 'Workflow does not publish the image directory.' },
        @{ Pattern = 'touch _site/\.nojekyll'; Message = 'Workflow does not create .nojekyll in the Pages artifact.' }
    )

    foreach ($requirement in $requiredPatterns) {
        if ($workflow -notmatch $requirement.Pattern) {
            $failures.Add($requirement.Message)
        }
    }
}

if ($failures.Count -gt 0) {
    $message = ($failures | ForEach-Object { "- $_" }) -join [Environment]::NewLine
    throw "GitHub Pages contract failed:`n$message"
}

Write-Host 'GitHub Pages contract passed.'
