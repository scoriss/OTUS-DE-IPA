import os
from pathlib import Path
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.utils.dates import datetime
from ipa_common import S3Yandex, MoexIss

DBT_PROJECT_DIR = os.environ.get('DBT_PROJECT_DIR', '/ipa_project/dbt')
INITIAL_DATA_DIR = os.environ.get('INITIAL_DATA_DIR', '/ipa_project/initial_data')
S3_BUCKET = os.environ.get('S3_BUCKET')

TEMP_ROOT_DIR = os.path.join(Path(DBT_PROJECT_DIR).resolve().parent, 'temp')

def upload_initial_data():
    s3_client = S3Yandex()
    s3_client.delete_object_by_prefix(S3_BUCKET, 'data')
    s3_client.upload_folder(INITIAL_DATA_DIR, S3_BUCKET, 'data')

def upload_shares_data():
    s3_client = S3Yandex()
    moex_client = MoexIss()
    shares_pd = moex_client.get_shares()
    if len(shares_pd.index) > 0:
        shares_pd.to_csv(os.path.join(TEMP_ROOT_DIR, 'shares/shares.tsv'), sep='\t', 
            line_terminator='\n',header=True, index=False)
        s3_client.upload_file(os.path.join(TEMP_ROOT_DIR, 'shares/shares.tsv'), 
            S3_BUCKET, 'moex-data/current/shares/shares.tsv')
        
        shares_marketdata_pd = moex_client.get_shares_marketdata()
        shares_marketdata_pd.to_csv(os.path.join(TEMP_ROOT_DIR, 'shares/shares_marketdata.tsv'), sep='\t', 
            line_terminator='\n',header=True, index=False)
        s3_client.upload_file(os.path.join(TEMP_ROOT_DIR, 'shares/shares_marketdata.tsv'), 
            S3_BUCKET, 'moex-data/current/shares/shares_marketdata.tsv')

def upload_bonds_data():
    s3_client = S3Yandex()
    moex_client = MoexIss()
    bonds_pd = moex_client.get_bonds()
    if len(bonds_pd.index) > 0:
        bonds_pd.to_csv(os.path.join(TEMP_ROOT_DIR, 'bonds/bonds.tsv'), sep='\t', 
            line_terminator='\n',header=True, index=False)
        s3_client.upload_file(os.path.join(TEMP_ROOT_DIR, 'bonds/bonds.tsv'), 
            S3_BUCKET, 'moex-data/current/bonds/bonds.tsv')

        bonds_marketdata_pd = moex_client.get_bonds_marketdata()
        bonds_marketdata_pd.to_csv(os.path.join(TEMP_ROOT_DIR, 'bonds/bonds_marketdata.tsv'), sep='\t', 
            line_terminator='\n',header=True, index=False)
        s3_client.upload_file(os.path.join(TEMP_ROOT_DIR, 'bonds/bonds_marketdata.tsv'), 
            S3_BUCKET, 'moex-data/current/bonds/bonds_marketdata.tsv')

dag = DAG(
    "ipa_project_initialization",
    start_date=datetime(2021, 10, 1),
    default_args={"owner": "ipa_project", "email_on_failure": False},
    description="Airflow DAG for IPA Project initialization",
    schedule_interval=None,
    catchup=False,
    tags=['ipa'],
)

dbt_run_bsh_cmd = f"dbt run --project-dir {DBT_PROJECT_DIR}"

with dag:
    start_dummy = DummyOperator(task_id='start')

    dbt_init_s3_sources = BashOperator(
        task_id="dbt_init_s3_sources",
        bash_command=f"dbt run-operation init_s3_sources --project-dir {DBT_PROJECT_DIR}"
    )

    upload_initial_data = PythonOperator(task_id='upload_initial_data', python_callable=upload_initial_data, dag=dag)
    upload_shares_data = PythonOperator(task_id='upload_shares_data', python_callable=upload_shares_data, dag=dag)
    upload_bonds_data = PythonOperator(task_id='upload_bonds_data', python_callable=upload_bonds_data, dag=dag)

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=dbt_run_bsh_cmd
    )

    end_dummy = DummyOperator(task_id='end')

start_dummy >> [upload_initial_data, upload_shares_data, upload_bonds_data] >> dbt_init_s3_sources >> dbt_run >> end_dummy

