#!/bin/bash

# Accept env variable for PORT
{% if "nats" in cookiecutter.app_type %}
NATS_FASTAPI_PORT=${NATS_FASTAPI_PORT:-8000}
{% endif %}
{% if "fastapi" in cookiecutter.app_type %}
FASTAPI_PORT=${FASTAPI_PORT:-8008}
{% endif %}
{% if "mesop" in cookiecutter.app_type %}
MESOP_PORT=${MESOP_PORT:-8888}
{% endif %}
# Default number of workers if not set
WORKERS=${WORKERS:-1}
{% if "nats" in cookiecutter.app_type %}
# Run nats uvicorn server
uvicorn {{cookiecutter.project_slug}}.main_1_nats:app --host 0.0.0.0 --port $NATS_FASTAPI_PORT > /dev/stdout 2>&1 &
{% endif %}
# Run uvicorn server
uvicorn {{cookiecutter.project_slug}}.main_2_fastapi:app --host 0.0.0.0 --port $FASTAPI_PORT > /dev/stdout 2>&1 &

# Run gunicorn server
gunicorn --workers=$WORKERS {{cookiecutter.project_slug}}.main_3_mesop:app --bind 0.0.0.0:$MESOP_PORT
