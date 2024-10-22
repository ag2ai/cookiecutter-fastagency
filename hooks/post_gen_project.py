import os

REMOVE_PATHS = [
    "{% if cookiecutter.app_type == 'console' or cookiecutter.app_type == 'mesop' %}{{cookiecutter.project_slug}}/{{cookiecutter.project_slug}}/main_*.py{% endif %}"
]

for path in REMOVE_PATHS:
    print(path)
