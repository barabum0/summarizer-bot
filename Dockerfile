FROM python:3.12-slim AS poetry
LABEL authors="Roman Poltorabatko"
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y --no-install-recommends wget

RUN pip install poetry

RUN mkdir /opt/tiktoken_cache
ARG TIKTOKEN_URL="https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"
RUN wget -O /opt/tiktoken_cache/$(echo -n $TIKTOKEN_URL | sha1sum | head -c 40) $TIKTOKEN_URL

ENV TIKTOKEN_CACHE_DIR=/opt/tiktoken_cache

FROM poetry AS environment
WORKDIR /usr/src/app
COPY ./poetry.lock ./pyproject.toml /usr/src/app/

RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

FROM environment AS code
WORKDIR /usr/src/app
COPY . /usr/src/app

RUN mkdir /usr/src/app/logs || true
RUN poetry install

ENTRYPOINT ["poetry", "run", "app"]