FROM python:3-alpine as base

FROM base as builder

ADD . /setup
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev
RUN pip install --no-cache-dir --upgrade pip
RUN cd /setup && python setup.py install

FROM base

WORKDIR /opt

COPY --from=builder /usr/local/bin /usr/local/bin/
COPY --from=builder /usr/local/lib /usr/local/lib/
RUN apk add --no-cache postgresql-client libpq
RUN addgroup -S pgbouncer && adduser -S pgbouncer -G pgbouncer -h /tmp

ENV PGBOUNCER_DATABASE pgbouncer

VOLUME ["/etc/pgbouncer/", "/etc/userlist/"]

EXPOSE 5432
USER pgbouncer
ENTRYPOINT ["pgbouncer-config-reload", "-vv"]


