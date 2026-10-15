param(
    [Parameter(Mandatory = $true)]
    [string]$ScenarioRoot,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [string]$FileFilter = '*.json'
)

$ErrorActionPreference = 'Stop'
$records = [System.Collections.Generic.List[object]]::new()

function Add-EnglishFields {
    param(
        [object]$Node,
        [string]$File,
        [string]$Path
    )

    if ($null -eq $Node) { return }

    if ($Node -is [string] -or $Node -is [ValueType]) { return }

    if ($Node -is [System.Collections.IList]) {
        for ($i = 0; $i -lt $Node.Count; $i++) {
            Add-EnglishFields -Node $Node[$i] -File $File -Path "$Path[$i]"
        }
        return
    }

    $properties = @($Node.PSObject.Properties)
    if ($properties.Count -eq 0) { return }

    $languageProperty = $Node.PSObject.Properties['language']
    if ($null -ne $languageProperty -and $languageProperty.Value -is [System.Collections.IList]) {
        $languages = $languageProperty.Value
        if ($languages.Count -gt 1 -and $null -ne $languages[1]) {
            foreach ($field in 'disp', 'text', 'searchtext', 'speechtext') {
                $valueProperty = $languages[1].PSObject.Properties[$field]
                if ($null -ne $valueProperty -and $valueProperty.Value -is [string] -and $valueProperty.Value.Length -gt 0) {
                    $records.Add([pscustomobject]@{
                        id          = "$($File)::$Path.language[1].$field"
                        file        = $File
                        jsonPath    = "$Path.language[1].$field"
                        field       = $field
                        original    = $valueProperty.Value
                        translation = ''
                    })
                }
            }
        }
    }

    $textsProperty = $Node.PSObject.Properties['texts']
    if ($null -ne $textsProperty -and $textsProperty.Value -is [System.Collections.IList]) {
        $texts = $textsProperty.Value
        for ($textIndex = 0; $textIndex -lt $texts.Count; $textIndex++) {
            $entry = $texts[$textIndex]
            if ($entry -isnot [System.Collections.IList] -or $entry.Count -lt 2) { continue }

            $variants = $entry[1]
            if ($variants -isnot [System.Collections.IList] -or $variants.Count -lt 2) { continue }

            $english = $variants[1]
            if ($english -is [System.Collections.IList]) {
                foreach ($fieldInfo in @(
                    @{ Index = 0; Name = 'speaker' },
                    @{ Index = 1; Name = 'text' },
                    @{ Index = 3; Name = 'speechtext' },
                    @{ Index = 4; Name = 'searchtext' }
                )) {
                    if ($english.Count -gt $fieldInfo.Index -and $english[$fieldInfo.Index] -is [string] -and $english[$fieldInfo.Index].Length -gt 0) {
                        $records.Add([pscustomobject]@{
                            id          = "$($File)::$Path.texts[$textIndex][1][1][$($fieldInfo.Index)]"
                            file        = $File
                            jsonPath    = "$Path.texts[$textIndex][1][1][$($fieldInfo.Index)]"
                            field       = $fieldInfo.Name
                            original    = $english[$fieldInfo.Index]
                            translation = ''
                        })
                    }
                }
            }
        }
    }

    foreach ($property in $properties) {
        Add-EnglishFields -Node $property.Value -File $File -Path "$Path.$($property.Name)"
    }
}

$root = (Resolve-Path -LiteralPath $ScenarioRoot).Path
$files = Get-ChildItem -LiteralPath $root -Recurse -File -Filter $FileFilter | Sort-Object FullName
foreach ($file in $files) {
    try {
        $document = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        $relative = $file.FullName.Substring($root.Length).TrimStart('\')
        Add-EnglishFields -Node $document -File $relative -Path '$'
    }
    catch {
        Write-Warning "Skipped $($file.FullName): $($_.Exception.Message)"
    }
}

ConvertTo-Json -InputObject @($records) -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Exported $($records.Count) English fields to $OutputPath"
