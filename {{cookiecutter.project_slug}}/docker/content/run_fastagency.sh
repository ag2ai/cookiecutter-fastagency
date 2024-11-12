#!/bin/bash

# Accept env variable for PORT
{% if "nats" in cookiecutter.app_type %}
NATS_FASTAPI_PORT=${NATS_FASTAPI_PORT:-8000}
{% endif %}
{% if "fastapi" in cookiecutter.app_type %}
FASTAPI_PORT=${FASTAPI_PORT:-8008}
{% endif %}
export MESOP_PORT=${MESOP_PORT:-8888}

# Default number of workers if not set
WORKERS=${WORKERS:-1}
echo "Number of workers: $WORKERS"

# Generate nginx config
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((MESOP_PORT + i))
    sed -i "5i\    server 127.0.0.1:$PORT;" nginx.conf.template
done
envsubst '${MESOP_PORT}' < nginx.conf.template >/etc/nginx/conf.d/default.conf
echo "Nginx config:"
cat /etc/nginx/conf.d/default.conf

# Start nginx
nginx -g "daemon off;" &
{% if "nats" in cookiecutter.app_type %}
# Run nats uvicorn server
uvicorn {{cookiecutter.project_slug}}.deployment.main_1_nats:app --host 0.0.0.0 --port $NATS_FASTAPI_PORT > /dev/stdout 2>&1 &
{% endif %}
# Run uvicorn server
uvicorn {{cookiecutter.project_slug}}.deployment.main_{% if "nats" in cookiecutter.app_type %}2_fastapi{% elif "fastapi" in cookiecutter.app_type %}1_fastapi{% endif %}:app --host 0.0.0.0 --port $FASTAPI_PORT > /dev/stdout 2>&1 &
{% if "mesop" in cookiecutter.app_type %}
# Run gunicorn server
# Start multiple single-worker gunicorn instances on consecutive ports
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((MESOP_PORT + i))
    echo "Starting gunicorn on port $PORT"
    gunicorn --workers=1 {{cookiecutter.project_slug}}.deployment.main{% if "nats" in cookiecutter.app_type %}_3_mesop{% elif "fastapi" in cookiecutter.app_type %}_2_mesop{% endif %}:app --bind 0.0.0.0:$PORT > /dev/stdout 2>&1 &
done
{% endif %}
# Wait for all background processes
wait
