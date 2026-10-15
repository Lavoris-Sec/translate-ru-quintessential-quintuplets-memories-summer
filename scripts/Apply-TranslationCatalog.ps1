param(
    [Parameter(Mandatory = $true)]
    [string]$ScenarioRoot,

    [Parameter(Mandatory = $true)]
    [string]$CatalogPath
)

$ErrorActionPreference = 'Stop'

function Get-PathTokens {
    param([string]$JsonPath)

    if (-not $JsonPath.StartsWith('$')) {
        throw "Unsupported JSON path: $JsonPath"
    }

    $tokens = [System.Collections.Generic.List[object]]::new()
    foreach ($match in [regex]::Matches($JsonPath.Substring(1), '(?:\.([^\.\[]+)|\[([0-9]+)\])')) {
        if ($match.Groups[1].Success) {
            $tokens.Add($match.Groups[1].Value)
        }
        else {
            $tokens.Add([int]$match.Groups[2].Value)
        }
    }
    return @($tokens)
}

function Set-JsonValue {
    param(
        [object]$Document,
        [string]$JsonPath,
        [string]$Value
    )

    $tokens = Get-PathTokens -JsonPath $JsonPath
    if ($tokens.Count -eq 0) { throw "JSON path has no target: $JsonPath" }

    $current = $Document
    for ($i = 0; $i -lt $tokens.Count - 1; $i++) {
        $token = $tokens[$i]
        if ($token -is [int]) {
            $current = $current[$token]
        }
        else {
            $property = $current.PSObject.Properties[$token]
            if ($null -eq $property) { throw "Property '$token' was not found in $JsonPath" }
            $current = $property.Value
        }
    }

    $target = $tokens[$tokens.Count - 1]
    if ($target -is [int]) {
        $current[$target] = $Value
    }
    else {
        $property = $current.PSObject.Properties[$target]
        if ($null -eq $property) { throw "Property '$target' was not found in $JsonPath" }
        $property.Value = $Value
    }
}

$root = (Resolve-Path -LiteralPath $ScenarioRoot).Path
$records = @(Get-Content -LiteralPath $CatalogPath -Raw | ConvertFrom-Json | Where-Object {
    $_.translation -is [string] -and $_.translation.Trim().Length -gt 0
})

$changedFiles = 0
$changedFields = 0
foreach ($group in ($records | Group-Object file)) {
    $path = Join-Path $root $group.Name
    if (-not (Test-Path -LiteralPath $path)) { throw "Scenario file not found: $path" }

    $document = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    foreach ($record in $group.Group) {
        Set-JsonValue -Document $document -JsonPath $record.jsonPath -Value $record.translation
        $changedFields++
    }
    ConvertTo-Json -InputObject $document -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
    $changedFiles++
}

Write-Host "Applied $changedFields translations to $changedFiles scenario files."
