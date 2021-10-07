#!/usr/bin/env bash

# Setup DB Connection String
AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
export AIRFLOW__CORE__SQL_ALCHEMY_CONN

AIRFLOW__WEBSERVER__SECRET_KEY="openssl rand -hex 30"
export AIRFLOW__WEBSERVER__SECRET_KEY

rm -f /airflow/airflow-webserver.pid
rm -f /airflow/webserver_config.py

sleep 10
airflow db upgrade

sleep 10
airflow users create --email admin@email.com --firstname Admin \
    --lastname Admin --password airflow \
    --role Admin --username airflow

airflow scheduler & airflow webserver
