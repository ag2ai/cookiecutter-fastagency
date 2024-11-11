{%- if cookiecutter.authentication == "google" -%}
from pathlib import Path

import yaml
{% endif -%}
from fastagency.adapters.fastapi import FastAPIAdapter
from fastagency.app import FastAgency
from fastagency.ui.mesop import MesopUI{% if cookiecutter.authentication == "google" %}
from fastagency.ui.mesop.auth.firebase import FirebaseAuth, FirebaseConfig{% endif %}

fastapi_url = "http://localhost:8008"

provider = FastAPIAdapter.create_provider(
    fastapi_url=fastapi_url,
)

{%- if cookiecutter.authentication == "google" %}
with Path("firebase_config.yaml").open() as f:
    firebase_config = FirebaseConfig(**yaml.safe_load(f))
with Path("allowed_users.yaml").open() as f:
    allowed_users = yaml.safe_load(f)

auth = FirebaseAuth(
    sign_in_methods=["google"],
    config=firebase_config,
    allowed_users=allowed_users,
)

ui = MesopUI(auth=auth)
{% else %}
ui = MesopUI()
{% endif %}

app = FastAgency(
    provider=provider,
    ui=MesopUI(),
    title="{{cookiecutter.project_name}}",
)

# start the provider with the following command
# gunicorn {{cookiecutter.project_slug}}.deployment.main_{% if "nats" in cookiecutter.app_type %}3{% else %}2{% endif %}_mesop:app -b 0.0.0.0:8888 --reload
