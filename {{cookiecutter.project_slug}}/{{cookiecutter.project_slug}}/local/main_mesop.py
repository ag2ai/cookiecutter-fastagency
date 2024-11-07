from fastagency import FastAgency
from fastagency.ui.mesop import MesopUI

from ..workflow import wf

app = FastAgency(
    provider=wf,
    ui=MesopUI(),
    title="{{cookiecutter.project_name}}",
)

# start the fastagency app with the following command
# gunicorn {{cookiecutter.project_slug}}.local.main_mesop:app
