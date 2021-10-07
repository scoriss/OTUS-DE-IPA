FROM python:3.8

COPY requirements.txt .
RUN pip install --upgrade pip setuptools && \
    pip install -r requirements.txt && \
    pip install 'apache-airflow[postgres]==2.1.4'

RUN mkdir -p /usr/local/share/ca-certificates/Yandex && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt && \
    chmod 655 /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt

RUN mkdir /scripts
COPY scripts/ /scripts/

RUN chmod +x /scripts/init.sh
ENTRYPOINT [ "/scripts/init.sh" ]
