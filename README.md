# Проектная работа по курсу **[Data Engineer](https://otus.ru/lessons/data-engineer)** от **[OTUS](https://otus.ru/)**

**Анализ доходности инвестиционного портфеля (Investment Portfolio Analysis)**<br>
Система получения данных с API Московской биржи ([MOEX ISS](https://www.moex.com/a2193)) и анализ доходности портфеля.<br>
`Yandex.Cloud`, `Airflow`, `S3 Object Storage`, `DBT`, `ClickHouse`, `Yandex DataLens`

Оценка эффективности инвестиций с учетом комиссий, налогов, дивидендов и купонов.<br> 
На основе сгенерированного датасета c операциям инвестиционного портфеля.
## Архитектура проекта
![project_architecture](https://user-images.githubusercontent.com/18349305/141770652-b253ab49-060a-4cd5-a372-df6f7c88a77e.jpg)

## Используемые технологии
* **[Airflow](https://airflow.apache.org/)** - Получение и обработка данных с API Московской биржи ([MOEX ISS](https://www.moex.com/a2193)). Оркестрация DBT.
* **[S3 Object Storage](https://cloud.yandex.ru/services/storage)** - Хранение внешних данных для последующей обработки и загрузки в ClickHouse.
* **[DBT](https://www.getdbt.com/)** - Автоматизация обработки и трансформации данных проекта.
* **[Yandex Managed Service for ClickHouse](https://cloud.yandex.ru/services/managed-clickhouse)** - Колоночная аналитическая СУБД для хранения и обработки данных.
* **[Yandex DataLens](https://cloud.yandex.ru/services/datalens)** - Визуализация данных и бизнес-аналитика.
* **[Docker](https://www.docker.com/)** - Контейнеризация готового приложения.

## Проект
### Настройка проекта
Настроить необходимые переменные окружения для проекта в файле **[.env](.env)**

### Запуск проекта
```Bash 
docker-compose up --build -d
```
Открыть интерфейс **Airflow** перейдя по ссылке http://localhost:8000/ при локальной установке<br>
или по адресу хоста в случае облачной установки http://host_ip:8000/

1. Для первоначальной инициализации проекта запустить DAG - **[ipa_project_initialization](airflow/dags/ipa_project_initialization.py)**
2. Для дальнейшей работы и обновления данных снять с паузы DAG - **[ipa_project_workload](airflow/dags/ipa_project_workload.py)**

### Генерация документации DBT

```Bash 
docker exec -it airdbt bash
cd ipa_project/dbt/
dbt docs generate
dbt docs serve --port 8090 --no-browser
```
Перейти по ссылке http://localhost:8090/ при локальной установке<br>
или по адресу хоста в случае облачной установки http://host_ip:8090/


### Завершение работы
```Bash 
docker-compose down -v
docker rmi otus-de-ipa:1.0
```

## Визуализация данных в Yandex DataLens

### Портфель
![Портфель](https://user-images.githubusercontent.com/18349305/141804532-e37a9e04-ff3e-41b6-a429-837c66877fb4.jpg)

### Операции
![Операции](https://user-images.githubusercontent.com/18349305/141804074-06f33a00-9694-42bf-9316-f7940567df4a.jpg)

### Графики
![Графики](https://user-images.githubusercontent.com/18349305/141805536-67318d75-4cb3-404a-a1f6-91e2d3faba59.jpg)

