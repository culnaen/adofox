# Adofox

Firefox ESR 52.9.0 с Adobe Flash Player 32.0.0.363 (Linux x86_64, NPAPI) в контейнере Ubuntu 16.04. ESR 52 поддерживает NPAPI Flash; версия Flash 32.0.0.363 не содержит блокировки запуска содержимого после окончания поддержки Adobe.

## Запуск

Требуются Linux x86_64, Docker, `xauth` и работающий X11 или Xwayland (`DISPLAY` и сокет `/tmp/.X11-unix`). Пользователю нужен доступ к Docker daemon. Образ собирается с загрузкой Firefox из [архива Mozilla](https://ftp.mozilla.org/pub/firefox/releases/52.9.0esr/) и Linux-плагина из [архива Flash](https://archive.org/details/flashplayerarchive); SHA-256 архива Flash проверяется при сборке.

```sh
docker build -t adofox .
./adofox
```

Открыть адрес сразу:

```sh
./adofox 'https://10.0.19.12:9443/vsphere-client/'
```

Для клиента vSphere образ генерирует локали `en_US.UTF-8` и `ru_RU.UTF-8`: без них Flash выдаёт `TypeError: Error #2007` при создании `flash.globalization.NumberFormatter`.

При падении после входа проверьте память контейнера: в исходной конфигурации Docker выделял `/dev/shm` всего 64 МиБ. В дампах сбоя Firefox и Flash получен `SIGBUS` (сигнал 7); нехватка разделяемой памяти — вероятная, но не доказанная причина. `./adofox` выделяет 1 ГиБ через `--shm-size`. После обновления скрипта закройте старый контейнер и запустите браузер снова; пересборка образа для этой настройки не требуется. [Mozilla описывает SIGBUS при нехватке `/dev/shm`](https://bugzilla.mozilla.org/show_bug.cgi?id=1245239).

Проверка плагина: `./adofox about:plugins` — **Shockwave Flash 32.0.0.363**. Перед повторным запуском закройте предыдущее окно браузера: один и тот же профиль Firefox нельзя использовать двумя процессами одновременно. Профиль и настройки сохраняются в `~/.adofox`. Файлы из `~/adofox-share` доступны в браузере по пути `/home/adofox` (только чтение). В отличие от Javafox, весь домашний каталог хоста не монтируется: старый Flash не должен получать доступ к ключам SSH и другим личным файлам.

Сайт с самоподписанным сертификатом может потребовать добавления исключения **только после проверки сертификата**. Firefox и Flash устарели и содержат известные уязвимости: используйте контейнер только для доверенных устаревших ресурсов, не для обычного веб-серфинга. Контейнеру доступны сеть и X11-сервер хоста; это не строгая изоляция от вредоносного содержимого.

## Совместимость версий

Страница `10.0.19.12:9443/vsphere-client/` запрашивает Flash **11.5.0 или новее**. Установленный Linux NPAPI Flash **32.0.0.363** удовлетворяет этому минимуму; версия совпадает с работающей у вас на Windows. [Firefox 51.0.1](https://ftp.mozilla.org/pub/firefox/releases/51.0.1/linux-x86_64/en-US/) есть и для Linux, но успех связки Firefox 51 + Flash на Windows не доказывает её работоспособность на Linux. Текущий [Firefox 52 ESR поддерживает Flash](https://support.mozilla.org/en-US/kb/npapi-plugins); смену версии без проверки причины сбоя не делаем.

В [руководстве VMware для vSphere 5.5](https://vmware360.com/files/pdf/products/vsphere/vsphere-esxi-vcenter-server-55-installation-setup-guide.pdf) среди поддерживаемых клиентских ОС указаны Windows и Mac, не Linux. [Руководство vSphere 6.0](https://www.dogrubilisim.com/uploads/pdf/6484-vsphere-esxi-vcenter-server-60-installation-setup-guide.pdf) требует Flash 16+ и прямо исключает Linux (на момент публикации его Flash был только 11.2). Подтверждённой VMware «оптимальной» пары Firefox/Flash для Linux нет. Если увеличение `/dev/shm` не поможет, нужен новый дамп падения и версия vSphere: по одному падению нельзя обоснованно выбирать другой релиз Flash.
