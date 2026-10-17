param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$ScenarioRoot
)

$ErrorActionPreference = 'Stop'

$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
if (-not $ScenarioRoot) {
    $ScenarioRoot = Join-Path $RepositoryRoot 'work\goto01\scenario\scenario'
}
$ScenarioRoot = (Resolve-Path -LiteralPath $ScenarioRoot).Path

$translationRoot = Join-Path $RepositoryRoot 'translation'
$manifestPath = Join-Path $translationRoot 'goto01-apply-manifest.json'
$dialogueScript = Join-Path $PSScriptRoot 'Apply-DialogueBlock.ps1'
$catalogScript = Join-Path $PSScriptRoot 'Apply-TranslationCatalog.ps1'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

function Apply-DialoguePatch {
    param(
        [string]$ScenarioFile,
        [string]$PatchFile
    )

    $scenarioPath = Join-Path $ScenarioRoot $ScenarioFile
    $patchPath = Join-Path $translationRoot $PatchFile
    if (-not (Test-Path -LiteralPath $scenarioPath)) { throw "Scenario file not found: $scenarioPath" }
    if (-not (Test-Path -LiteralPath $patchPath)) { throw "Patch file not found: $patchPath" }

    & $dialogueScript -ScenarioPath $scenarioPath -TranslationsPath $patchPath
}

# The opening uses legacy patch names, so its required order lives in the manifest.
foreach ($patch in @($manifest.openingPatches)) {
    Apply-DialoguePatch -ScenarioFile 'op_01.txt.scn.m.json' -PatchFile $patch
}

# Every chapter patch follows goto01-caNN_NN-*.json and is applied alphabetically.
# New translation patches therefore need no README or script edits.
$chapterPatches = @(Get-ChildItem -LiteralPath $translationRoot -File -Filter 'goto01-ca*.json' |
    Where-Object {
        $_.Name -match '^goto01-(ca\d{2}_\d{2})(?:-.+)?\.json$' -and
        $_.Name -notmatch '-choices\.json$'
    } |
    Sort-Object Name)

foreach ($patch in $chapterPatches) {
    $match = [regex]::Match($patch.Name, '^goto01-(ca\d{2}_\d{2})(?:-.+)?\.json$')
    Apply-DialoguePatch -ScenarioFile "$($match.Groups[1].Value).txt.scn.m.json" -PatchFile $patch.Name
}

foreach ($catalog in @($manifest.catalogs)) {
    $catalogPath = Join-Path $translationRoot $catalog
    if (-not (Test-Path -LiteralPath $catalogPath)) { throw "Catalog file not found: $catalogPath" }
    & $catalogScript -ScenarioRoot $ScenarioRoot -CatalogPath $catalogPath
}

Write-Host "All translations have been applied."
