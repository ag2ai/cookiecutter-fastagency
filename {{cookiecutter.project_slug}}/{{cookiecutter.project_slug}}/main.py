from fastagency import FastAgency
{% if cookiecutter.app_type == "console" %}from fastagency.ui.console import ConsoleUI{% elif cookiecutter.app_type == "mesop" %}from fastagency.ui.mesop import MesopUI{% endif %}

from .workflow import wf


app = FastAgency(
    provider=wf,
    ui={% if cookiecutter.app_type == "console" %}ConsoleUI{% elif cookiecutter.app_type == "mesop" %}MesopUI{% endif %}(),
    title="{{cookiecutter.project_name}}",
)
