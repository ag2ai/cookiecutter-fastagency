{%- if cookiecutter.authentication == "google" -%}
from pathlib import Path

import yaml
{% endif -%}
from fastagency.adapters.fastapi import FastAPIAdapter
from fastagency.app import FastAgency
from fastagency.ui.mesop import MesopUI{% if cookiecutter.authentication == "google" %}
from fastagency.ui.mesop.auth.firebase import FirebaseAuth, FirebaseConfig{% elif cookiecutter.authentication == "basic" %}
from fastagency.ui.mesop.auth.basic_auth import BasicAuth{% endif %}

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
{%- elif cookiecutter.authentication == "basic" %}
auth = BasicAuth(
    # TODO: Replace `allowed_users` with the desired usernames and their
    # bcrypt-hashed passwords. One way to generate bcrypt-hashed passwords
    # is by using online tools such as https://bcrypt.online
    # Default password for all users is `password`
    allowed_users={
        "admin": "$2y$10$ZgcGQlsvMoMRmmW4Y.nUVuVHc.vOJsOA7iXAPXWPFy9DX2S7oeTDa",  # nosemgrep: generic.secrets.security.detected-bcrypt-hash.detected-bcrypt-hash
        "user@example.com": "$2y$10$ZgcGQlsvMoMRmmW4Y.nUVuVHc.vOJsOA7iXAPXWPFy9DX2S7oeTDa",  # nosemgrep: generic.secrets.security.detected-bcrypt-hash.detected-bcrypt-hash
    },
)

ui = MesopUI(auth=auth)
{% else %}
ui = MesopUI()
{% endif %}

app = FastAgency(
    provider=provider,
    ui=ui,
    title="{{cookiecutter.project_name}}",
)

# start the provider with the following command
# gunicorn {{cookiecutter.project_slug}}.deployment.main_{% if "nats" in cookiecutter.app_type %}3{% else %}2{% endif %}_mesop:app -b 0.0.0.0:8888 --reload
