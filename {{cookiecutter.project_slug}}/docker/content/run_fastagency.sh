#!/bin/bash

# Accept env variable for PORT
{% if "nats" in cookiecutter.app_type %}
NATS_FASTAPI_PORT=${NATS_FASTAPI_PORT:-8000}
{% endif %}
{% if "fastapi" in cookiecutter.app_type %}
FASTAPI_PORT=${FASTAPI_PORT:-8008}
{% endif %}
{% if "mesop" in cookiecutter.app_type %}
export MESOP_PORT=${MESOP_PORT:-8888}
export TO_EXPOSE_SERVICE_PORT=$MESOP_PORT
{% else %}
export TO_EXPOSE_SERVICE_PORT=$FASTAPI_PORT
{% endif %}
# Default number of workers if not set
WORKERS=${WORKERS:-1}
echo "Number of workers: $WORKERS"

# Check FLY_MACHINE_ID is set, if not set, set it to dummy value
export FLY_MACHINE_ID=${FLY_MACHINE_ID:-dummy_fly_machine_id_value}
echo "Fly machine ID: $FLY_MACHINE_ID"

# Generate nginx config
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((TO_EXPOSE_SERVICE_PORT + i))
    sed -i "5i\    server 127.0.0.1:$PORT;" nginx.conf.template
done
envsubst '${TO_EXPOSE_SERVICE_PORT},${FLY_MACHINE_ID}' < nginx.conf.template >/etc/nginx/conf.d/default.conf
echo "Nginx config:"
cat /etc/nginx/conf.d/default.conf

# Start nginx
nginx -g "daemon off;" &
{% if "nats" in cookiecutter.app_type %}
# Run nats uvicorn server
uvicorn {{cookiecutter.project_slug}}.deployment.main_1_nats:app --host 0.0.0.0 --port $NATS_FASTAPI_PORT > /dev/stdout 2>&1 &
{% endif %}
{% if cookiecutter.app_type == "fastapi" %}
# Run uvicorn server
# Start multiple single-worker uvicorn instances on consecutive ports
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((TO_EXPOSE_SERVICE_PORT + i))
    echo "Starting gunicorn on port $PORT"
    uvicorn {{cookiecutter.project_slug}}.deployment.main_1_fastapi:app --workers=1 --host 0.0.0.0 --port $PORT > /dev/stdout 2>&1 &
done
{% else %}
# Run uvicorn server
uvicorn {{cookiecutter.project_slug}}.deployment.main_{% if "nats" in cookiecutter.app_type %}2_fastapi{% elif "fastapi" in cookiecutter.app_type %}1_fastapi{% endif %}:app --host 0.0.0.0 --port $FASTAPI_PORT > /dev/stdout 2>&1 &
{% endif %}
{% if "mesop" in cookiecutter.app_type %}
# Run gunicorn server
# Start multiple single-worker gunicorn instances on consecutive ports
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((TO_EXPOSE_SERVICE_PORT + i))
    echo "Starting gunicorn on port $PORT"
    gunicorn --workers=1 {{cookiecutter.project_slug}}.deployment.main{% if "nats" in cookiecutter.app_type %}_3_mesop{% elif "fastapi" in cookiecutter.app_type %}_2_mesop{% endif %}:app --bind 0.0.0.0:$PORT > /dev/stdout 2>&1 &
done
{% endif %}
# Wait for all background processes
wait
