#!/bin/bash

docker run -it -e OPENAI_API_KEY=$OPENAI_API_KEY {% if cookiecutter.authentication == "google"%}-e GOOGLE_APPLICATION_CREDENTIALS="serviceAccountKey.json"{% endif %} {% if "nats" in cookiecutter.app_type %}-e NATS_URL=$NATS_URL -e FASTAGENCY_NATS_PASSWORD=$FASTAGENCY_NATS_PASSWORD -p 8000:8000{% endif %}{% if "fastapi" in cookiecutter.app_type %} -p 8008:8008{% endif %}{% if "mesop" in cookiecutter.app_type %} -p 8888:8888{% endif %}{% if "nats" in cookiecutter.app_type %} --network=host{% endif %} deploy_fastagency
