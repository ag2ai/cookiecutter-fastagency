import os
from typing import Any

from autogen.agentchat import ConversableAgent
from fastapi import FastAPI

from fastagency import UI
{% if "nats" in cookiecutter.app_type %}from fastagency.adapters.nats import NatsAdapter{% else %}from fastagency.adapters.fastapi import FastAPIAdapter{% endif %}
from fastagency.runtimes.autogen import AutoGenWorkflows

llm_config = {
    "config_list": [
        {
            "model": "gpt-4o-mini",
            "api_key": os.getenv("OPENAI_API_KEY"),
        }
    ],
    "temperature": 0.8,
}

wf = AutoGenWorkflows()


@wf.register(name="simple_learning", description="Student and teacher learning chat")
def simple_workflow(ui: UI, params: dict[str, Any]) -> str:
    initial_message = ui.text_input(
        sender="Workflow",
        recipient="User",
        prompt="I can help you learn about mathematics. What subject you would like to explore?",
    )

    student_agent = ConversableAgent(
        name="Student_Agent",
        system_message="You are a student willing to learn.",
        llm_config=llm_config,
        # human_input_mode="ALWAYS",
    )
    teacher_agent = ConversableAgent(
        name="Teacher_Agent",
        system_message="You are a math teacher.",
        llm_config=llm_config,
        # human_input_mode="ALWAYS",
    )

    chat_result = student_agent.initiate_chat(
        teacher_agent,
        message=initial_message,
        summary_method="reflection_with_llm",
        max_turns=5,
    )

    return chat_result.summary  # type: ignore[no-any-return]

{% if "nats" in cookiecutter.app_type %}
nats_url = os.environ.get("NATS_URL", "nats://localhost:4222")
user: str = "fastagency"
password: str = os.environ.get("FASTAGENCY_NATS_PASSWORD", "fastagency_nats_password")  # type: ignore[assignment]

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
# uvicorn main_1_{% if "nats" in cookiecutter.app_type %}nats{% else %}fastapi{% endif %}:app --reload
