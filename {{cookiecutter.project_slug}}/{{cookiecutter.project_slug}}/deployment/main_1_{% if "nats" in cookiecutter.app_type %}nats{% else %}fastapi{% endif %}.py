{% if "nats" in cookiecutter.app_type -%}
import os
{% endif %}
{%- if "mesop" in cookiecutter.app_type or "fastapi" in cookiecutter.app_type %}from typing import Any{% endif %}

{% if "nats" in cookiecutter.app_type %}from fastagency.adapters.nats import NatsAdapter{% else %}from fastagency.adapters.fastapi import FastAPIAdapter{% endif %}
from fastapi import FastAPI{% if cookiecutter.app_type == 'fastapi' %}
from fastapi.responses import HTMLResponse{%- endif %}

from ..workflow import wf

{%- if "nats" in cookiecutter.app_type %}

nats_url = os.environ.get("NATS_URL", "nats://localhost:4222")
user: str = os.environ.get("FASTAGENCY_NATS_USER", "fastagency")
password: str = os.environ.get("FASTAGENCY_NATS_PASSWORD", "fastagency_nats_password")

adapter = NatsAdapter(provider=wf, nats_url=nats_url, user=user, password=password)

app = FastAPI(lifespan=adapter.lifespan)
{%- else %}

adapter = FastAPIAdapter(provider=wf)

app = FastAPI()
app.include_router(adapter.router)
{%- endif %}

{% if cookiecutter.app_type == 'fastapi' %}
html = """
<!DOCTYPE html>
<html>
   <head>
      <title>FastAgency Chat App</title>
   </head>
   <body>
      <h1>FastAgency Chat App</h1>
      <div id="workflows"></div>
      <ul id="messages"></ul>
      <script>
         const API_URL = 'http://127.0.0.1:8008/fastagency';
         const WS_URL = 'ws://127.0.0.1:8008/fastagency/ws'; // nosemgrep
         let socket;

         async function fetchWorkflows() {
             const response = await fetch(`${API_URL}/discovery`);
             const workflows = await response.json();
             const container = document.getElementById('workflows');
             workflows.forEach(workflow => {
                 const button = document.createElement('button');
                 button.textContent = workflow.description;
                 button.onclick = () => startWorkflow(workflow.name);
                 container.appendChild(button);
             });
         }

         async function startWorkflow(name) {
             const payload = {
                 workflow_name: name,
                 workflow_uuid: generateUUID(),
                 user_id: null, // Set to null for single-user applications; otherwise, provide the appropriate user ID
                 params: {}
             };
             const response = await fetch(`${API_URL}/initiate_workflow`, {
                 method: 'POST',
                 headers: { 'Content-Type': 'application/json' },
                 body: JSON.stringify(payload)
             });
             const workflowJson = await response.json();
             connectWebSocket(workflowJson);
         }

         function connectWebSocket(workflowJson) {
             socket = new WebSocket(WS_URL);
             socket.onopen = () => {
                 const initMessage = {
                     name: workflowJson.name,
                     workflow_uuid: workflowJson.workflow_uuid,
                     user_id: workflowJson.user_id,
                     params: {}
                 };
                 socket.send(JSON.stringify(initMessage));
             };
             socket.onmessage = (event) => handleMessage(JSON.parse(event.data));
         }

         function handleMessage(message) {
             const messagesList = document.getElementById('messages');
             const li = document.createElement('li');
             if (message.type === 'text_input') {
                 const response = prompt(message.content.prompt);
                 socket.send(response);
                 li.textContent = `${message.sender} -> ${message.recipient}: ${message.content.prompt}`;
             } else {
                 li.textContent = `${message.sender} -> ${message.recipient}: ${message.content?.body || message?.type || JSON.stringify(message)}`;
             }
             messagesList.appendChild(li);
         }

         fetchWorkflows();

         // Helper function for generating UUID
         function generateUUID() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                if (c === 'x') {
                return (Math.random() * 16 | 0).toString(16);
                } else {
                return (Math.random() * 16 | 0 & 0x3 | 0x8).toString(16);
                }
            });
         }
      </script>
   </body>
</html>
"""


@app.get("/")
async def get() -> HTMLResponse:
    return HTMLResponse(html)


# this is optional, but we would like to see the list of available workflows
@app.get("/workflows")
def list_workflows() -> dict[str, Any]:
    return {"Workflows": {name: wf.get_description(name) for name in wf.names}}
{% else %}
# this is optional, but we would like to see the list of available workflows
@app.get("/")
def list_workflows() -> dict[str, Any]:
    return {"Workflows": {name: wf.get_description(name) for name in wf.names}}
{% endif %}

# start the adapter with the following command
# uvicorn {{cookiecutter.project_slug}}.deployment.main_1_{% if "nats" in cookiecutter.app_type %}nats{% else %}fastapi{% endif %}:app --reload
