#!/bin/bash

# Accept env variable for PORT
export NATS_FASTAPI_PORT=${NATS_FASTAPI_PORT:-8000}
export FASTAPI_PORT=${FASTAPI_PORT:-8008}
export MESOP_PORT=${MESOP_PORT:-8888}

# Default number of workers if not set
WORKERS=${WORKERS:-1}
echo "Number of workers: $WORKERS"

# Check FLY_MACHINE_ID is set, if not set, set it to dummy value
export FLY_MACHINE_ID=${FLY_MACHINE_ID:-dummy_fly_machine_id_value}
echo "Fly machine ID: $FLY_MACHINE_ID"

# Generate nginx config
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((MESOP_PORT + i))
    sed -i "19i\    server 127.0.0.1:$PORT;" nginx.conf.template
done

for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((FASTAPI_PORT + i))
    sed -i "12i\    server 127.0.0.1:$PORT;" nginx.conf.template
done

for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((NATS_FASTAPI_PORT + i))
    sed -i "5i\    server 127.0.0.1:$PORT;" nginx.conf.template
done

envsubst '${NATS_FASTAPI_PORT},${FASTAPI_PORT},${MESOP_PORT},${FLY_MACHINE_ID}' < nginx.conf.template >/etc/nginx/conf.d/default.conf
echo "Nginx config:"
cat /etc/nginx/conf.d/default.conf

# Start nginx
nginx -g "daemon off;" &
{% if "nats" in cookiecutter.app_type %}
# Run nats uvicorn server
# Start multiple single-worker uvicorn instances on consecutive ports
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((NATS_FASTAPI_PORT + i))
    echo "Starting nats fastapi uvicorn on port $PORT"
    uvicorn {{cookiecutter.project_slug}}.deployment.main_1_nats:app --workers=1 --host 0.0.0.0 --port $PORT > /dev/stdout 2>&1 &
done
{% endif %}
{% if "fastapi" in cookiecutter.app_type %}
# Run uvicorn server
# Start multiple single-worker uvicorn instances on consecutive ports
for ((i=1; i<$WORKERS+1; i++))
do
	PORT=$((FASTAPI_PORT + i))
    echo "Starting fastapi uvicorn on port $PORT"
    uvicorn {{cookiecutter.project_slug}}.deployment.main{% if "nats" in cookiecutter.app_type %}_2_fastapi{% elif "fastapi" in cookiecutter.app_type %}_1_fastapi{% endif %}:app --workers=1 --host 0.0.0.0 --port $PORT > /dev/stdout 2>&1 &
done
{% endif %}
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
