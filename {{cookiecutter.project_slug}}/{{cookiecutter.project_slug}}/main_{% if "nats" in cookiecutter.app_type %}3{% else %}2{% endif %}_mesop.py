from fastagency.adapters.fastapi import FastAPIAdapter
from fastagency.app import FastAgency
from fastagency.ui.mesop import MesopUI

fastapi_url = "http://localhost:8008"

provider = FastAPIAdapter.create_provider(
    fastapi_url=fastapi_url,
)

app = FastAgency(
    provider=provider,
    ui=MesopUI(),
    title="{{cookiecutter.project_name}}",
)

# start the provider with the following command
# gunicorn {{cookiecutter.project_slug}}.main_{% if "nats" in cookiecutter.app_type %}3{% else %}2{% endif %}_mesop:app -b 0.0.0.0:8888 --reload
