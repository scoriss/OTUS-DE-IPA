# Анализ доходности инвестиционного портфеля (Investment Portfolio Analysis)

Проектная работа по курсу **[Data Engineer](https://otus.ru/lessons/data-engineer)** от **[OTUS](https://otus.ru/)**.

Система получения данных с API Московской биржи ([MOEX ISS](https://www.moex.com/a2193)) и анализ доходности портфеля, на основе датасета c демонстрационными операциям.  Визуализация данных в **[Yandex DataLens](https://cloud.yandex.ru/services/datalens)**.<br>
`Yandex Cloud`, `Airflow`, `DBT`, `Docker`, `Yandex Object Storage`, `ClickHouse`, `Yandex DataLens`

Оценка эффективности инвестиций с учетом комиссий, налогов, дивидендов и купонов.

**[Презентация проекта](documents/presentation.pdf)**.

**[Анализ доходности инвестиционного портфеля](https://datalens.yandex/g2hy8czkk7gi9)** - Демонстрация дашборда.<br>
*Данные материализованы на 19.11.2021 17:40, без последующего обновления.*

:information_source: На момент публикации проекта, в **Yandex DataLens** отсутствует возможность экспорта/импорта всех связанных объектов дашборда для переноса.

## Архитектура проекта
![project_architecture](https://user-images.githubusercontent.com/18349305/142174598-bcfee23d-3d35-4481-ab99-a11f8f3e8ae7.jpg)

## Используемые технологии и продукты
* **[Docker](https://www.docker.com/)** - Контейнеризация приложений проекта (**Airflow**, **DBT**,  requirements).
* **[Airflow](https://airflow.apache.org/)** - Получение и обработка данных с API Московской биржи ([MOEX ISS](https://www.moex.com/a2193)). Оркестрация **DBT**.
* **[Yandex Object Storage](https://cloud.yandex.ru/services/storage)** - Облачное объектное хранилище (`AWS S3 API compatible`).<br>
    Хранение внешних данных для последующей обработки и загрузки в базу данных **ClickHouse** (`S3 Table Engine`).
* **[DBT](https://www.getdbt.com/)** - Автоматизация обработки и трансформации данных проекта в СУБД **ClickHouse**.
* **[Yandex Managed Service for ClickHouse](https://cloud.yandex.ru/services/managed-clickhouse)** - Колоночная аналитическая СУБД для хранения и обработки данных.
* **[Yandex DataLens](https://cloud.yandex.ru/services/datalens)** - Облачный сервис для визуализации данных и бизнес-аналитики.

## Проект

### Настройка проекта

1. Для работы проекта необходимы:
   * Экземпляр СУБД **ClickHouse** (*Версия: 21.8 и выше*)
   * Бакет в **Yandex Object Storage**.<br>
    Endpoint (https://storage.yandexcloud.net) прописан в файлах **[s3_yandex.py](airflow/include/ipa_common/s3_yandex.py)** и **[init_s3_sources.sql](dbt/macros/init_s3_sources.sql)**.<br>
2. Настроить необходимые переменные окружения в файле **[.env](.env)**
   
<details><summary><strong>Инструкция по настройке необходимой инфраструктуры в Yandex Cloud :cloud:</strong></summary>

1. [Создать сервисный аккаунт](https://cloud.yandex.ru/docs/iam/operations/sa/create) необходимый для работы всех служб.
2. [Назначить роль](https://cloud.yandex.ru/docs/iam/operations/sa/assign-role-for-sa) сервисному аккаунту **storage.editor**.
3. [Создать статический ключ доступа](https://cloud.yandex.ru/docs/iam/operations/sa/create-access-key) **ACCESS KEY** для сервисного аккаунта.
4. [Создать бакет](https://cloud.yandex.ru/docs/storage/operations/buckets/create) в Object Storage.
5. [Отредактировать ACL бакета](https://cloud.yandex.ru/docs/storage/operations/buckets/edit-acl) - добавить сервисный аккаунт (*Шаг 1*) с правами **FULL_CONTROL**.
6. [Создать виртуальную машину Linux](https://cloud.yandex.ru/docs/compute/quickstart/quick-create-linux) (*Операционная система: Ubuntu 20.04*).
7. Установить **docker** и **docker-compose** на виртуальную машину:<br><br>
    ```Bash 
    # Install docker
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add --
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -a -G docker $USER

    # Install docker-compose
    sudo apt-get -y install wget
    sudo wget https://github.com/docker/compose/releases/download/v2.1.0/docker-compose-$(uname -s)-$(uname -m) -O /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo chmod 666 /var/run/docker.sock
    ```
8. [Создать кластер](https://cloud.yandex.ru/docs/managed-clickhouse/operations/cluster-create) **ClickHouse** (*Версия: 21.8 LTS и выше*).
   * Сервисный аккаунт - Выбрать сервисный аккаунт (*Шаг 1*).
   * Хосты -> Редактировать хост -> Включить опцию **Публичный доступ** (*При необходимости подключения к кластеру из интернета*)
   * Включить опцию **Доступ из DataLens**.

</details>

### Запуск проекта
```Bash 
docker-compose up -d
```

Откройте интерфейс **Airflow** перейдя по адресу:
* При локальном запуске - http://localhost:8000/
* В случае облачной установки, по адресу хоста - http://host:8000/


Последовательно выполните действия:
1. Для первоначальной инициализации проекта запустить DAG - **[ipa_project_initialization](airflow/dags/ipa_project_initialization.py)**
2. Для дальнейшей работы и обновления данных снять с паузы DAG - **[ipa_project_workload](airflow/dags/ipa_project_workload.py)**


### Генерация документации DBT

Для возможности просмотра документации **DBT** открыт порт **8090** в контейнере.

Выполните комманды:
```Bash 
docker exec -it airdbt bash

cd ipa_project/dbt/
dbt docs generate
dbt docs serve --port 8090 --no-browser
```
Откройте документацию **DBT** перейдя по адресу:
* При локальном запуске - http://localhost:8090/
* В случае облачной установки, по адресу хоста - http://host:8090/


### Завершение работы
```Bash 
docker-compose down -v
docker rmi otus-de-ipa:1.0
```

## Визуализация данных в Yandex DataLens

Некоторые ограничения при визуализации данных:
* Округление чисел до двух знаков после запятой при визуализации, без возможности выбора формата отображения.
* Нет возможности выделения цветом отдельных ячеек таблицы в зависимости от условий или формулы.
* Нет возможности настроить ширину колонок.

### Портфель
![Портфель](https://user-images.githubusercontent.com/18349305/142235009-b68ac152-c1e1-4d3a-baac-407a0702ab87.jpg)

### Операции
![Операции](https://user-images.githubusercontent.com/18349305/141804074-06f33a00-9694-42bf-9316-f7940567df4a.jpg)

### Графики
![Графики](https://user-images.githubusercontent.com/18349305/142234531-36d61590-a58f-41cc-aea8-c9e7eccaf3de.jpg)

### Торговый день
![Торговый день](https://user-images.githubusercontent.com/18349305/142234757-d30b3ae8-de6a-4882-b82d-acf8e2c1a5bb.jpg)

## Полезные ресурсы
* Документация [Программный интерфейс к MOEX ISS](https://www.moex.com/a2193)
* Онлайн-справочник запросов к MOEX API: http://iss.moex.com/iss/reference/<br>
    Префиксом к описанным в нем запросам является: http://iss.moex.com/
* Чат ClickHouse в телеграм: https://t.me/clickhouse_ru
* Altinity ClickHouse [Knowledge Base](https://kb.altinity.com/)
* Марафон по DataLens: https://datayoga.ru/datalensbook
* Чат DataLens в телеграм: https://t.me/YandexDataLens
