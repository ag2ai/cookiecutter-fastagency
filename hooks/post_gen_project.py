import glob
import os
import shutil

REMOVE_PATHS = [
    {% if cookiecutter.app_type == 'mesop' %}"{{cookiecutter.project_slug}}/deployment/main_*.py",{% endif %}
    {% if 'fastapi' in cookiecutter.app_type %}"{{cookiecutter.project_slug}}/deployment/main.py",{% endif %}
    {% if 'nats' not in cookiecutter.app_type %}"{{cookiecutter.project_slug}}/deployment/main_2_fastapi.py",{% endif %}
    {% if 'nats' not in cookiecutter.app_type %}".devcontainer/nats_server.conf",{% endif %}
    {% if cookiecutter.app_type == 'fastapi' %}"{{cookiecutter.project_slug}}/deployment/main_2_mesop.py",{% endif %}
    {% if cookiecutter.authentication != 'google' %}"deployment/",{% endif %}
    {% if cookiecutter.deployment != 'fly.io' %}"scripts/register_to_fly_io.sh",{% endif %}
    {% if cookiecutter.deployment != 'fly.io' %}"scripts/deploy_to_fly_io.sh",{% endif %}
    {% if cookiecutter.deployment != 'fly.io' %}"fly.toml",{% endif %}
    {% if cookiecutter.deployment != 'fly.io' %}".github/workflows/deploy_to_fly_io.yml",{% endif %}
    {% if cookiecutter.deployment != 'azure' %}"scripts/deploy_to_azure.sh",{% endif %}
]

for path in REMOVE_PATHS:
    path = path.strip()
    if not path:
        continue
    paths = list(glob.glob(path)) if "*" in path else [path]

    for p in paths:
        if p and os.path.exists(p):
            if os.path.isdir(p):
                shutil.rmtree(p, ignore_errors=True)
            else:
                os.unlink(p)
