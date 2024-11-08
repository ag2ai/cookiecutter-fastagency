import json
from pathlib import Path

PROJECT_NAME = "My FastAgency App"
PROJECT_SLUG = "my_fastagency_app"

APP_TYPES = ["fastapi+mesop", "mesop", "nats+fastapi+mesop"]

PYTHON_VERSIONS = ["3.12", "3.11", "3.10"]


def generate_cookiecutter_replay():
    for app_type in APP_TYPES:
        for python_version in PYTHON_VERSIONS:
            print(f"Generating cookiecutter replay for {app_type} with Python {python_version}")
            cookiecutter_replay = {
                "cookiecutter": {
                    "project_name": PROJECT_NAME,
                    "project_slug": PROJECT_SLUG,
                    "app_type": app_type,
                    "python_version": python_version,
                }
            }

            # Write to cookiecutter replay file
            replay_file = Path(__file__).parent.parent.resolve() / "cookiecutter_replay" / f"{app_type}_{python_version}.json"

            with open(replay_file, "w") as f:
                json.dump(cookiecutter_replay, f, indent=4)


if __name__ == "__main__":
    generate_cookiecutter_replay()
