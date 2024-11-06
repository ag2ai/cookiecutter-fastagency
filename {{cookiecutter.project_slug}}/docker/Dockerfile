FROM python:{{cookiecutter.python_version}}

WORKDIR /app

# Install nginx
RUN apt-get update && apt-get install -y --no-install-recommends nginx gettext \
    && rm -rf /var/lib/apt/lists/*

COPY {{cookiecutter.project_slug}} /app/{{cookiecutter.project_slug}}

COPY pyproject.toml README.md docker/run_fastagency.sh docker/nginx.conf.template /app/

# COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

RUN pip install --upgrade pip && pip install --no-cache-dir -e "."

# RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app

# USER appuser

EXPOSE 8000 8008 8888

CMD ["/app/run_fastagency.sh"]

# Run the build command from root of fastagency repo
# docker build -t deploy_fastagency -f docker/Dockerfile .

# Run the container
{% if "nats" in cookiecutter.app_type %}
# NATS docker container should be running already
{% endif %}
# docker run --rm -d --name deploy_fastagency -e OPENAI_API_KEY=$OPENAI_API_KEY {% if "nats" in cookiecutter.app_type %}-e NATS_URL=$NATS_URL -e FASTAGENCY_NATS_PASSWORD=$FASTAGENCY_NATS_PASSWORD -p 8000:8000{% endif %}{% if "fastapi" in cookiecutter.app_type %} -p 8008:8008{% endif %} -p 8888:8888 {% if "nats" in cookiecutter.app_type %}--network=host{% endif %} deploy_fastagency
