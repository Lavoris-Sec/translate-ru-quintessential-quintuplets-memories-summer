param(
    [Parameter(Mandatory = $true)]
    [string]$ScenarioPath,

    [Parameter(Mandatory = $true)]
    [string]$TranslationsPath
)

$ErrorActionPreference = 'Stop'
$document = Get-Content -LiteralPath $ScenarioPath -Raw | ConvertFrom-Json
$translations = @(Get-Content -LiteralPath $TranslationsPath -Raw | ConvertFrom-Json)

foreach ($translation in $translations) {
    $values = $document.scenes[[int]$translation.scene].texts[[int]$translation.text][1][1]
    if ($values -isnot [System.Collections.IList] -or $values.Count -lt 2) {
        throw "Unexpected dialogue structure for scene $($translation.scene), text $($translation.text)."
    }

    if ($translation.PSObject.Properties['speaker'] -and $translation.speaker -is [string] -and $translation.speaker.Length -gt 0) {
        $values[0] = $translation.speaker
    }

    if ($translation.PSObject.Properties['translation'] -and $translation.translation -is [string] -and $translation.translation.Length -gt 0) {
        $values[1] = $translation.translation
        $flatText = $translation.translation -replace '\\n', ' '
        if ($values.Count -gt 3) { $values[3] = $flatText }
        if ($values.Count -gt 4) { $values[4] = $flatText }
    }
}

ConvertTo-Json -InputObject $document -Depth 100 | Set-Content -LiteralPath $ScenarioPath -Encoding UTF8
Write-Host "Applied $($translations.Count) dialogue entries."
