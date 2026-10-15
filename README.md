# Русификация The Quintessential Quintuplets: Memories of a Quintessential Summer

Здесь находятся только скрипты и JSON-патчи перевода. Файлов игры, её архивов, резервных копий и сторонних утилит в репозитории нет.

## Готово

Переведены `op_01`, `ca01_01`, `ca01_02` и `ca01_03`.

## Что установить

1. Лицензионную Steam-версию игры.
2. [Git для Windows](https://git-scm.com/download/win).
3. [FreeMote Toolkit — официальные релизы](https://github.com/UlyssesWu/FreeMote/releases). Распакуйте его, например, в `D:\translate\tools\FreeMote`.

## Новый компьютер: подготовка

```powershell
git clone https://github.com/Lavoris-Sec/translate-ru-quintessential-quintuplets-memories-summer.git D:\translate\goto-ru
New-Item -ItemType Directory -Force D:\translate\goto-ru\work\goto01 | Out-Null
```

Закройте игру. Папка игры обычно находится здесь:

```text
<SteamLibrary>\steamapps\common\goto01\windata
```

Создайте резервную копию сценария, заменив `W:` на свой диск Steam:

```powershell
$game = 'W:\SteamLibrary\steamapps\common\goto01\windata'
$backup = 'D:\translate\goto-ru\backup\goto01-scenario-original'
New-Item -ItemType Directory -Force $backup | Out-Null
Copy-Item "$game\scenario_info.psb.m", "$game\scenario_body.bin" -Destination $backup
```

## Распаковка

```powershell
$tool = 'D:\translate\tools\FreeMote\PsbDecompile.exe'
$game = 'W:\SteamLibrary\steamapps\common\goto01\windata'
$work = 'D:\translate\goto-ru\work\goto01\scenario'
& $tool info-psb -k 523aad2de7132 -l 131 "$game\scenario_info.psb.m" -o $work -a
```

Сценарии появятся в `$work\scenario`.

## Применение переводов

```powershell
$repo = 'D:\translate\goto-ru'
$scenario = 'D:\translate\goto-ru\work\goto01\scenario\scenario'

$patches = @(
  @{f='op_01.txt.scn.m.json'; p='goto01-opening-test.json'},
  @{f='op_01.txt.scn.m.json'; p='goto01-op01-opening.json'},
  @{f='op_01.txt.scn.m.json'; p='goto01-op01-live-test.json'},
  @{f='op_01.txt.scn.m.json'; p='goto01-op01-dock-01.json'},
  @{f='op_01.txt.scn.m.json'; p='goto01-op01-dock-02.json'},
  @{f='op_01.txt.scn.m.json'; p='goto01-op01-dock-03.json'},
  @{f='ca01_01.txt.scn.m.json'; p='goto01-ca01_01-part1.json'},
  @{f='ca01_01.txt.scn.m.json'; p='goto01-ca01_01-part2.json'},
  @{f='ca01_02.txt.scn.m.json'; p='goto01-ca01_02-part1.json'},
  @{f='ca01_02.txt.scn.m.json'; p='goto01-ca01_02-part2.json'},
  @{f='ca01_03.txt.scn.m.json'; p='goto01-ca01_03-part1.json'},
  @{f='ca01_03.txt.scn.m.json'; p='goto01-ca01_03-part2a.json'},
  @{f='ca01_03.txt.scn.m.json'; p='goto01-ca01_03-part2b.json'},
  @{f='ca01_03.txt.scn.m.json'; p='goto01-ca01_03-part3.json'}
)
foreach ($patch in $patches) {
  & "$repo\scripts\Apply-DialogueBlock.ps1" -ScenarioPath "$scenario\$($patch.f)" -TranslationsPath "$repo\translation\$($patch.p)"
}
& "$repo\scripts\Apply-TranslationCatalog.ps1" -ScenarioRoot $scenario -CatalogPath "$repo\translation\goto01-ca01_02-choices.json"
```

## Сборка и установка

FreeMote записывает результат в текущую папку PowerShell, поэтому собирать нужно не в папке игры:

```powershell
$builder = 'D:\translate\tools\FreeMote\PsBuild.exe'
$build = 'D:\translate\goto-ru\work\build'
New-Item -ItemType Directory -Force $build | Out-Null
Set-Location $build
& $builder info-psb 'D:\translate\goto-ru\work\goto01\scenario\scenario_info.psb.m.json'
```

Дождитесь строки `Done.`, затем при закрытой игре:

```powershell
Copy-Item "$build\scenario_info.psb.m" -Destination "$game\scenario_info.psb.m" -Force
Copy-Item "$build\scenario_body.bin" -Destination "$game\scenario_body.bin" -Force
```

## Важно

- Steam-проверка целостности вернёт оригинальные архивы.
- Не загружайте файлы игры в репозиторий.
- Русский шрифт и системный интерфейс пока настроены в локальной рабочей копии отдельно; сценарные диалоги по инструкции воспроизводятся полностью.
