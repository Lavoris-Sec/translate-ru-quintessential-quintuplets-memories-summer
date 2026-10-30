# Русификация The Quintessential Quintuplets: Memories of a Quintessential Summer

Здесь находятся только скрипты и JSON-патчи перевода. Файлов игры, её архивов, резервных копий и сторонних утилит в репозитории нет.

> [!IMPORTANT]
> Это неофициальный некоммерческий патч. Он не содержит файлов игры и требует легальную Steam-копию. Все права на игру и её оригинальный текст принадлежат правообладателям. Если вы правообладатель и считаете, что материал нарушает ваши права, создайте issue или свяжитесь с владельцем репозитория - материал будет рассмотрен и при необходимости удалён.

## Прогресс перевода

Перевод **ещё не завершён**. В игре есть дополнительные сценарии помимо 164 файлов вступления и основных глав, поэтому считать 164/164 за 100% всей игры нельзя.

В патчах подготовлены:

- Диалоги вступления `op_01`–`op_05` и основных глав `ca01`–`ca07` (164 файла), а также добавленные каталоги вариантов выбора. Полнота выбора и связанных записей ещё требует повторной проверки.
- Дополнительные диалоги `cl01`–`cl05` (20 файлов), сцены готовки `co01`–`co05` (15 файлов) и реакции на блюда `ea01`–`ea30` (90 файлов).
- Сцена `go_01`, концовка `ed01_01`, обучение `tu01_01` и `tu02_01` с вариантами выбора.
- Каталог из 116 системных строк. Отдельные графические меню пока остаются английскими.

Остальные дополнительные сцены, концовки и интерфейс требуют перевода и проверки. Новые патчи проверены применением к копиям исходных сценариев; полная сборка и проверка новых блоков в игре не подтверждены. Общий процент завершённости пока не установлен.

## Что установить

1. Лицензионную Steam-версию игры.
2. [Git для Windows](https://git-scm.com/download/win).
3. [FreeMote Toolkit - официальные релизы](https://github.com/UlyssesWu/FreeMote/releases). Распакуйте его, например, в `D:\translate\tools\FreeMote`.

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

## Возврат английского оригинала

Закройте игру и восстановите два исходных файла из резервной копии:

```powershell
$game = 'W:\SteamLibrary\steamapps\common\goto01\windata'
$backup = 'D:\translate\goto-ru\backup\goto01-scenario-original'
Copy-Item "$backup\scenario_info.psb.m", "$backup\scenario_body.bin" -Destination $game -Force
```

Если резервной копии уже нет, в Steam откройте свойства игры → «Установленные файлы» → «Проверить целостность файлов». Steam заново загрузит оригинальные архивы.

## Распаковка

```powershell
$tool = 'D:\translate\tools\FreeMote\PsbDecompile.exe'
$game = 'W:\SteamLibrary\steamapps\common\goto01\windata'
$work = 'D:\translate\goto-ru\work\goto01\scenario'
& $tool info-psb -k 523aad2de7132 -l 131 "$game\scenario_info.psb.m" -o $work -a
```

Сценарии появятся в `$work\scenario`.

## Применение переводов

После распаковки скрипт применяет патчи из манифеста, автоматически находит патчи основных глав `goto01-caNN_NN-*.json` и применяет каталоги. Дополнительные сценарные патчи и каталоги необходимо включать в `translation/goto01-apply-manifest.json`.

```powershell
$repo = 'D:\translate\goto-ru'
& "$repo\scripts\Apply-AllTranslations.ps1"
```

Ниже оставлен старый ручной список как справка для проверки и нестандартных случаев. Новые патчи в него добавлять не требуется.

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
  @{f='ca01_03.txt.scn.m.json'; p='goto01-ca01_03-part3.json'},
  @{f='ca01_04.txt.scn.m.json'; p='goto01-ca01_04-part1.json'},
  @{f='ca01_04.txt.scn.m.json'; p='goto01-ca01_04-part2.json'},
  @{f='ca01_05.txt.scn.m.json'; p='goto01-ca01_05-part1.json'},
  @{f='ca01_05.txt.scn.m.json'; p='goto01-ca01_05-part2a.json'},
  @{f='ca01_05.txt.scn.m.json'; p='goto01-ca01_05-part2b.json'},
  @{f='ca01_05.txt.scn.m.json'; p='goto01-ca01_05-part3.json'},
  @{f='ca01_06.txt.scn.m.json'; p='goto01-ca01_06-part1.json'},
  @{f='ca01_06.txt.scn.m.json'; p='goto01-ca01_06-part2.json'},
  @{f='ca01_06.txt.scn.m.json'; p='goto01-ca01_06-part3a.json'},
  @{f='ca01_06.txt.scn.m.json'; p='goto01-ca01_06-part3b.json'},
  @{f='ca01_06.txt.scn.m.json'; p='goto01-ca01_06-part4.json'},
  @{f='ca01_07.txt.scn.m.json'; p='goto01-ca01_07-part1.json'},
  @{f='ca01_07.txt.scn.m.json'; p='goto01-ca01_07-part2.json'},
  @{f='ca01_07.txt.scn.m.json'; p='goto01-ca01_07-part3.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part1.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part2.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part3.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part4.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part5.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part6.json'},
  @{f='ca01_08.txt.scn.m.json'; p='goto01-ca01_08-part7.json'},
  @{f='ca01_09.txt.scn.m.json'; p='goto01-ca01_09-part1.json'},
  @{f='ca01_09.txt.scn.m.json'; p='goto01-ca01_09-part2.json'},
  @{f='ca01_09.txt.scn.m.json'; p='goto01-ca01_09-part3.json'},
  @{f='ca01_09.txt.scn.m.json'; p='goto01-ca01_09-part4.json'},
  @{f='ca01_09.txt.scn.m.json'; p='goto01-ca01_09-part5.json'},
  @{f='ca01_10.txt.scn.m.json'; p='goto01-ca01_10-part1.json'},
  @{f='ca01_10.txt.scn.m.json'; p='goto01-ca01_10-part2.json'},
  @{f='ca01_11.txt.scn.m.json'; p='goto01-ca01_11-part1.json'},
  @{f='ca01_12.txt.scn.m.json'; p='goto01-ca01_12-part1.json'},
  @{f='ca01_12.txt.scn.m.json'; p='goto01-ca01_12-part2.json'},
  @{f='ca01_12.txt.scn.m.json'; p='goto01-ca01_12-part3.json'},
  @{f='ca01_13.txt.scn.m.json'; p='goto01-ca01_13-part1.json'},
  @{f='ca01_13.txt.scn.m.json'; p='goto01-ca01_13-part2.json'},
  @{f='ca01_14.txt.scn.m.json'; p='goto01-ca01_14-part1.json'},
  @{f='ca01_14.txt.scn.m.json'; p='goto01-ca01_14-part2.json'},
  @{f='ca01_14.txt.scn.m.json'; p='goto01-ca01_14-part3.json'},
  @{f='ca01_14.txt.scn.m.json'; p='goto01-ca01_14-part4.json'},
  @{f='ca01_15.txt.scn.m.json'; p='goto01-ca01_15-part1.json'},
  @{f='ca01_15.txt.scn.m.json'; p='goto01-ca01_15-part2.json'},
  @{f='ca01_16.txt.scn.m.json'; p='goto01-ca01_16-part1.json'},
  @{f='ca01_17.txt.scn.m.json'; p='goto01-ca01_17-part1.json'},
  @{f='ca01_17.txt.scn.m.json'; p='goto01-ca01_17-part2.json'},
  @{f='ca01_17.txt.scn.m.json'; p='goto01-ca01_17-part3.json'},
  @{f='ca01_17.txt.scn.m.json'; p='goto01-ca01_17-part4.json'},
  @{f='ca01_17.txt.scn.m.json'; p='goto01-ca01_17-part5.json'},
  @{f='ca01_18.txt.scn.m.json'; p='goto01-ca01_18-part1.json'},
  @{f='ca01_18.txt.scn.m.json'; p='goto01-ca01_18-part2.json'},
  @{f='ca01_18.txt.scn.m.json'; p='goto01-ca01_18-part3.json'},
  @{f='ca01_18.txt.scn.m.json'; p='goto01-ca01_18-part4.json'},
  @{f='ca01_19.txt.scn.m.json'; p='goto01-ca01_19-part1.json'},
  @{f='ca01_19.txt.scn.m.json'; p='goto01-ca01_19-part2.json'},
  @{f='ca02_01.txt.scn.m.json'; p='goto01-ca02_01-part1.json'},
  @{f='ca02_01.txt.scn.m.json'; p='goto01-ca02_01-part2.json'},
  @{f='ca02_02.txt.scn.m.json'; p='goto01-ca02_02-part1.json'},
  @{f='ca02_02.txt.scn.m.json'; p='goto01-ca02_02-part2.json'},
  @{f='ca02_03.txt.scn.m.json'; p='goto01-ca02_03-part1.json'},
  @{f='ca02_03.txt.scn.m.json'; p='goto01-ca02_03-part2.json'},
  @{f='ca02_03.txt.scn.m.json'; p='goto01-ca02_03-part3.json'},
  @{f='ca02_03.txt.scn.m.json'; p='goto01-ca02_03-part4.json'},
  @{f='ca02_04.txt.scn.m.json'; p='goto01-ca02_04.json'},
  @{f='ca02_05.txt.scn.m.json'; p='goto01-ca02_05.json'},
  @{f='ca02_06.txt.scn.m.json'; p='goto01-ca02_06-part1.json'},
  @{f='ca02_06.txt.scn.m.json'; p='goto01-ca02_06-part2.json'},
  @{f='ca02_06.txt.scn.m.json'; p='goto01-ca02_06-part3.json'},
  @{f='ca02_06.txt.scn.m.json'; p='goto01-ca02_06-part4.json'},
  @{f='ca02_07.txt.scn.m.json'; p='goto01-ca02_07-part1.json'},
  @{f='ca02_07.txt.scn.m.json'; p='goto01-ca02_07-part2.json'},
  @{f='ca02_07.txt.scn.m.json'; p='goto01-ca02_07-part3.json'},
  @{f='ca02_08.txt.scn.m.json'; p='goto01-ca02_08-part1.json'},
  @{f='ca02_08.txt.scn.m.json'; p='goto01-ca02_08-part2.json'},
  @{f='ca02_09.txt.scn.m.json'; p='goto01-ca02_09.json'},
  @{f='ca02_10.txt.scn.m.json'; p='goto01-ca02_10-part1.json'},
  @{f='ca02_10.txt.scn.m.json'; p='goto01-ca02_10-part2.json'}
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
- Файлы игры в репозиторий не загружаются.
- Скрипт применяет текстовые патчи к распакованным сценариям и конфигурации; шрифт и архив конфигурации требуют отдельной подготовки и сборки. Подписи отдельных графических меню, включая экран настроек, пока могут оставаться английскими.
