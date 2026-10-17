# Продолжение русификации goto01

Эта заметка нужна для нового чата Codex. Перед продолжением прочитать её целиком.

## Цель

Некоммерческий русский патч для Steam-игры **The Quintessential Quintuplets: Memories of a Quintessential Summer** (`goto01`). В репозитории лежат только JSON-патчи и скрипты, **не файлы игры**.

## Пути

- Репозиторий: `D:\translate\goto-ru`
- Распакованная рабочая копия сценариев: `D:\translate\goto-ru\goto01\scenario\scenario`
- Метаданные архива для сборки: `D:\translate\goto-ru\goto01\scenario\scenario_info.psb.m.json`
- Инструменты FreeMote: `D:\translate\goto-ru\tools`
- Сборка всегда появляется в: `D:\App\scenario_info.psb.m` и `D:\App\scenario_body.bin`
- Установленная Steam-игра: `W:\SteamLibrary\steamapps\common\goto01\windata`
- Оригинальные архивы сценариев: `D:\translate\goto-ru\backup\goto01-scenario-original`
- PSB-ключ: `523aad2de7132`; длина: `131`

## Текущий прогресс

- Всего сценариев: 160 (`op_01` + 159 сценариев `ca01`–`ca07`).
- В рабочей копии готовы: `op_01`, вся первая глава `ca01_01`–`ca01_19` и `ca02_01`–`ca02_24`.
- Это 44 / 160 сценариев (28%). Следующий сценарий: **`ca02_25.txt.scn.m.json`**.
- До конца второй главы остался `ca02_25`, затем главы 3–7 (115 сценариев).
- Последний локальный и удалённый коммит после веб-правки README: `1e7fb74 Fix formatting`.
- Перед началом продолжения выполнить `git status --short` и при необходимости `git pull --ff-only origin main`.

## Что установлено в игру

Последняя **подтверждённо скопированная в игру** сборка содержит перевод до `ca02_10`. Перед следующим запуском нужно пересобрать и установить актуальную версию.

Пользователь договорился: когда он просит «коммит/пуш» или явно говорит, что игра закрыта, игру можно считать закрытой для установки. Однако после каждой сборки сначала нужно проверить результат, и только затем копировать архивы.

## Создание и применение патчей

Патчи лежат в `D:\translate\goto-ru\translation` и называются так:

`goto01-ca02_21-part1.json`, `goto01-ca02_21-part2.json`, и т. п.

У патча структура:

```json
[
  {"scene": 0, "text": 0, "speaker": "Футаро", "translation": "Русский текст"}
]
```

Для применения нового патча:

```powershell
& 'D:\translate\goto-ru\scripts\Apply-DialogueBlock.ps1' `
  -ScenarioPath 'D:\translate\goto-ru\goto01\scenario\scenario\ca02_21.txt.scn.m.json' `
  -TranslationsPath 'D:\translate\goto-ru\translation\goto01-ca02_21-part1.json'
```

Диалог в JSON находится в `scenes[scene].texts[text][1][1]`: нулевой элемент — говорящий, первый — строка. При переводе сохранять управляющие теги вроде `%p-2;――` и переводы строк `\n`.

Чтобы посмотреть строки сценария, использовать PowerShell (в системе нет `rg`). Типичный шаблон уже много раз использовался в истории чата: пройти циклом по `scenes` и `texts`, собрать записи с `N`, `Scene`, `Text`, `Speaker`, `English`.

## Автоматическое применение всего перевода

Создан скрипт:

```powershell
$repo = 'D:\translate\goto-ru'
& "$repo\scripts\Apply-AllTranslations.ps1"
```

Он применяет вступление в порядке из `translation\goto01-apply-manifest.json`, сам находит сценарные патчи `goto01-caNN_NN-*.json`, а затем применяет каталог вариантов выбора. Старый длинный список в README больше не обновлять.

Скрипт также применяет `translation/goto01-interface-system-text.json`: это 116 переведённых системных строк (сохранение, загрузка, подтверждения, выход, имена, разблокировки). Статические надписи экрана настроек в этот каталог не входят: они находятся в отдельных графических/скомпилированных ресурсах и требуют отдельного исследования.

## Сборка, проверка, установка

Собирать **из `D:\App`**, иначе результат окажется в неправильной папке:

```powershell
& 'D:\translate\goto-ru\tools\PsBuild.exe' info-psb `
  'D:\translate\goto-ru\goto01\scenario\scenario_info.psb.m.json'
```

`PsBuild.exe` иногда возвращает управление раньше, чем завершает упаковку. Проверять, что процесс `PsBuild` исчез и оба файла `D:\App\scenario_info.psb.m` / `scenario_body.bin` получили свежие время и ненулевой размер.

Проверять сборку распаковкой в отдельную временную папку и поиском одного нового русского текста:

```powershell
& 'D:\translate\goto-ru\tools\PsbDecompile.exe' info-psb `
  -k 523aad2de7132 -l 131 `
  'D:\App\scenario_info.psb.m' -o 'D:\App\scenario-verify' -a
```

Только после проверки и при закрытой игре устанавливать:

```powershell
$game = 'W:\SteamLibrary\steamapps\common\goto01\windata'
Copy-Item -LiteralPath 'D:\App\scenario_info.psb.m','D:\App\scenario_body.bin' -Destination $game -Force
```

Русский шрифт уже отдельно настроен в локальной копии игры; русский текст отображался корректно. Статические пункты интерфейса могут оставаться английскими, потому что они находятся в скомпилированных Squirrel-скриптах.

После перевода системных сообщений нужно также собрать и установить архив конфигурации:

```powershell
& 'D:\translate\goto-ru\tools\PsBuild.exe' info-psb `
  'D:\translate\goto-ru\goto01\config\config_info.psb.m.json'
Copy-Item -LiteralPath 'D:\App\config_info.psb.m','D:\App\config_body.bin' -Destination $game -Force
```

## Git и README

- Remote: `https://github.com/Lavoris-Sec/translate-ru-quintessential-quintuplets-memories-summer.git`
- При контрольной точке: обновить верхний блок прогресса README, `git add README.md translation/goto01-ca02_*.json`, затем коммит и `git push origin HEAD`.
- README теперь содержит общий прогресс-бар и список полностью завершённых глав. После `ca02_25` перенести вторую главу в маркированный список «Полностью переведено».
- Не добавлять новые патчи в старый ручной список README: автоскрипт их обнаруживает сам.
- Если пользователь отредактировал README в веб-интерфейсе GitHub, сначала сделать `git pull --ff-only origin main`.

## Стиль работы

- Пользователь общается по-русски, неформально; «давай/погнали» — разрешение продолжать перевод автономно.
- По возможности брать большие блоки, не останавливаться после каждой небольшой части.
- Не коммитить и не пушить без прямой просьбы. При просьбе «коммит/пуш» также собрать и обновить игру, поскольку пользователь считает её закрытой.
- Перед любым копированием файлов в игру сначала собрать и проверить архив.
- Для редактирования файлов использовать `apply_patch`, а не `cat`/Python.
- Вне `D:\App` нужны команды с повышенным разрешением.
