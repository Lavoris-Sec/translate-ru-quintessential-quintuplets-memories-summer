param([string]$TestRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'build\test-patch-formats'))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force $TestRoot | Out-Null
$scenario = Join-Path $TestRoot 'sample.json'
$catalog = Join-Path $TestRoot 'catalog.json'
$dialogue = Join-Path $TestRoot 'dialogue.json'
'{"scenes":[{"texts":[[null,[null,["Futaro","Original",0,"Original","Original"]]]]}]}' | Set-Content -LiteralPath $scenario -Encoding UTF8
'[{"file":"sample.json","jsonPath":"$.scenes[0].texts[0][1][1][1]","translation":"Каталог"}]' | Set-Content -LiteralPath $catalog -Encoding UTF8
$before = (Get-FileHash -LiteralPath $scenario).Hash
$rejected = $false
try { & "$PSScriptRoot\Apply-DialogueBlock.ps1" -ScenarioPath $scenario -TranslationsPath $catalog }
catch { $rejected = $_.Exception.Message -like 'Invalid or missing*' }
if (-not $rejected -or (Get-FileHash -LiteralPath $scenario).Hash -ne $before) {
    throw 'A catalog must be rejected without changing the scenario.'
}
& "$PSScriptRoot\Apply-TranslationCatalog.ps1" -ScenarioRoot $TestRoot -CatalogPath $catalog
$doc = Get-Content -LiteralPath $scenario -Raw | ConvertFrom-Json
if ($doc.scenes[0].texts[0][1][1][1] -ne 'Каталог') { throw 'Catalog application failed.' }
'[{"scene":0,"text":0,"speaker":"Футаро","translation":"Первая\\nВторая"}]' | Set-Content -LiteralPath $dialogue -Encoding UTF8
& "$PSScriptRoot\Apply-DialogueBlock.ps1" -ScenarioPath $scenario -TranslationsPath $dialogue
$doc = Get-Content -LiteralPath $scenario -Raw | ConvertFrom-Json
$values = $doc.scenes[0].texts[0][1][1]
if ($values[0] -ne 'Футаро' -or $values[1] -ne 'Первая\nВторая' -or $values[3] -ne 'Первая Вторая' -or $values[4] -ne 'Первая Вторая') {
    throw 'Dialogue application or derived fields failed.'
}
Write-Host 'Patch format regression checks passed.'
