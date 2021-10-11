FROM python:3.8

COPY requirements.txt .
RUN pip install --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install 'apache-airflow[postgres]==2.1.4'

RUN mkdir -p /usr/local/share/ca-certificates/Yandex && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt && \
    chmod 655 /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt

RUN mkdir -p /ipa_project/scripts
COPY scripts/ /ipa_project/scripts/

RUN chmod +x /ipa_project/scripts/init.sh
ENTRYPOINT [ "/ipa_project/scripts/init.sh" ]
