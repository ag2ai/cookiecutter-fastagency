import os
from typing import Any

from fastapi import FastAPI
{% if "nats" in cookiecutter.app_type %}from fastagency.adapters.nats import NatsAdapter{% else %}from fastagency.adapters.fastapi import FastAPIAdapter{% endif %}

from ..workflow import wf

{% if "nats" in cookiecutter.app_type %}
nats_url = os.environ.get("NATS_URL", "nats://localhost:4222")
user: str = "fastagency"
password: str = os.environ.get("FASTAGENCY_NATS_PASSWORD", "fastagency_nats_password")

adapter = NatsAdapter(provider=wf, nats_url=nats_url, user=user, password=password)

app = FastAPI(lifespan=adapter.lifespan)
{% else %}
adapter = FastAPIAdapter(provider=wf)

app = FastAPI()
app.include_router(adapter.router)
{% endif %}

# this is optional, but we would like to see the list of available workflows
@app.get("/")
def list_workflows() -> dict[str, Any]:
    return {"Workflows": {name: wf.get_description(name) for name in wf.names}}


# start the adapter with the following command
# uvicorn {{cookiecutter.project_slug}}.deployment.main_1_{% if "nats" in cookiecutter.app_type %}nats{% else %}fastapi{% endif %}:app --reload
