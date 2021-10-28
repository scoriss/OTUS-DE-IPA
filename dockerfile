FROM python:3.8 AS compile-image

ENV VIRTUAL_ENV=/opt/venv_ipa
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install 'apache-airflow[postgres]==2.1.4'

RUN mkdir -p /usr/local/share/ca-certificates/Yandex && \
    wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt && \
    chmod 655 /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt

FROM python:3.8-slim AS build-image

COPY --from=compile-image /opt/venv_ipa /opt/venv_ipa
COPY --from=compile-image /usr/local/share/ca-certificates/Yandex /usr/local/share/ca-certificates/Yandex

ENV VIRTUAL_ENV=/opt/venv_ipa
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN mkdir -p /ipa_project/scripts
COPY scripts/ /ipa_project/scripts/

RUN chmod +x /ipa_project/scripts/init.sh
ENTRYPOINT [ "/ipa_project/scripts/init.sh" ]
