# {{cookiecutter.project_name}}

This repository contains a [`FastAgency`](https://github.com/airtai/fastagency) application which uses {% if cookiecutter.app_type == "console" %}Console{% else %}{% if "nats" in cookiecutter.app_type %}[NATS](https://nats.io/), {% endif %}{% if "fastapi" in cookiecutter.app_type %}[FastAPI](https://fastapi.tiangolo.com/), and {% endif %}{% if "mesop" in cookiecutter.app_type %}[Mesop](https://google.github.io/mesop/){% endif %}{% endif %}. Below, you'll find a guide on how to run the application.

## Running FastAgency Application

To run this [`FastAgency`](https://github.com/airtai/fastagency) application, follow these steps:

1. Open this folder with [vscode](https://code.visualstudio.com/).

2. Open the `.devcontainer/devcontainer.env` file and set your `OPENAI_API_KEY`. Alternatively, you can skip this step and set the `OPENAI_API_KEY` later in the terminal of the devcontainer.

3. Press `Ctrl+Shift+P` or `Cmd+Shift+P` and select the option `Dev Containers: Rebuild and Reopen in Container`. This will open the current repository in a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) using Docker and will install all the requirements to run the example application.
{% if "nats" in cookiecutter.app_type %}4. This example needs `NATS` to be up and running. `NATS` is automatically started by the devcontainer.{% endif %}
{% if "nats" in cookiecutter.app_type %}5{% else %}4{% endif %}. The `workflow.py` file defines the autogen workflows. It is imported and used in the files that define the `UI`.
{% if cookiecutter.app_type == "console" %}
5. The `main.py` file defines the `ConsoleUI`. In a devcontainer terminal, run the following command:

   ```bash
   fastagency run {{cookiecutter.project_slug}}/main.py
   ```
{% elif cookiecutter.app_type == "mesop" %}
5. The `main.py` file defines the `MesopUI`. In a devcontainer terminal, run the following command:

   ```bash
   fastagency run {{cookiecutter.project_slug}}/main.py
   ```

   Or you can use Python WSGI HTTP server like [gunicorn](https://gunicorn.org/) which is the preferred way to run the Mesop application. First, you need to install it using package manager such as `pip` and then run it as follows:

   ```bash
   pip install gunicorn
   gunicorn {{cookiecutter.project_slug}}.main:app
   ```

6. Open the Mesop UI URL [http://localhost:8888](http://localhost:8888) in your browser. You can now use the graphical user interface to start and run the autogen workflow.
{% elif cookiecutter.app_type == "fastapi+mesop" %}
5. The `main_1_fastapi.py` file defines the `FastAPIAdapter`. In a devcontainer terminal(**Terminal 1**), run the following command:

   ```bash
   uvicorn {{cookiecutter.project_slug}}.main_1_fastapi:app --host 0.0.0.0 --port 8008 --reload
   ```

6. The `main_2_mesop.py` file defines the `MesopUI`. In a new devcontainer terminal(**Terminal 2**), run the following command:

   ```bash
   gunicorn {{cookiecutter.project_slug}}.main_2_mesop:app -b 0.0.0.0:8888 --reload
   ```

7. Open the Mesop UI URL [http://localhost:8888](http://localhost:8888) in your browser. You can now use the graphical user interface to start and run the autogen workflow.
{% elif cookiecutter.app_type == "nats+fastapi+mesop" %}
6. The `main_1_nats.py` file defines the autogen workflows and includes the `NatsAdapter` to exchange the workflow conversation as messages via NATS. In a devcontainer terminal(**Terminal 1**), run the following command:

   ```bash
   uvicorn {{cookiecutter.project_slug}}.main_1_nats:app --reload
   ```

7. The `main_2_fastapi.py` file defines the `FastAPIAdapter`, which handles `NATS` messages using `NatsProvider`. In a new devcontainer terminal(**Terminal 2**), run the following command:

   ```bash
   uvicorn {{cookiecutter.project_slug}}.main_2_fastapi:app --host 0.0.0.0 --port 8008 --reload
   ```

8. Finally, the `main_3_mesop.py` file defines the `MesopUI`. In a new devcontainer terminal(**Terminal 3**), run the following command to start the mesop UI:

   ```bash
   gunicorn {{cookiecutter.project_slug}}.main_3_mesop:app -b 0.0.0.0:8888 --reload
   ```

9. Open the Mesop UI URL [http://localhost:8888](http://localhost:8888) in your browser. You can now use the graphical user interface to start and run the autogen workflow.
{% endif %}
## What's Next?

Once you’ve experimented with the default workflow in the `workflow.py` file, modify the autogen workflow to define your own workflows and try them out.
