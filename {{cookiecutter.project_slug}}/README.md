# {{cookiecutter.project_name}}

This repository contains a [`FastAgency`](https://github.com/airtai/fastagency) application which uses {% if cookiecutter.app_type == "console" %}Console{% else %}{% if "nats" in cookiecutter.app_type %}[NATS](https://nats.io/), {% endif %}{% if "fastapi" in cookiecutter.app_type %}[FastAPI](https://fastapi.tiangolo.com/), and {% endif %}{% if "mesop" in cookiecutter.app_type %}[Mesop](https://google.github.io/mesop/){% endif %}{% endif %}. Below, you'll find a guide on how to run the application.

## Running FastAgency Application

To run this [`FastAgency`](https://github.com/airtai/fastagency) application, follow these steps:

1. To run the `FastAgency` application, you need an API key for any LLM. The most commonly used LLM is [OpenAI](https://platform.openai.com/docs/models). To use it, create an [OpenAI API Key](https://openai.com/index/openai-api/) and set it as an environment variable in the terminal using the following command:

   ```bash
   export OPENAI_API_KEY=paste_openai_api_key_here
   ```

   If you want to use a different LLM provider, follow [this guide](https://fastagency.ai/latest/user-guide/runtimes/autogen/using_non_openai_models/).

   Alternatively, you can skip this step and set the LLM API key as an environment variable later in the devcontainer's terminal. If you open the project in `VSCode` using GUI, you will need to manually set the environment variable in the devcontainer's terminal.

   For [GitHub Codespaces](https://github.com/features/codespaces), you can set the LLM API key as a secret by following [this guide](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/configuring-dev-containers/specifying-recommended-secrets-for-a-repository), Or directly as an environment variable in the Codespaces' terminal.

2. Open this folder in [VSCode](https://code.visualstudio.com/) using the following command:

   ```bash
   code .
   ```

   If you are using GUI to open the project in `VSCode`, you will need to manually set the environment variable in the devcontainer's terminal.

   Alternatively, you can open this repository in [GitHub Codespaces](https://github.com/features/codespaces).

3. Press `Ctrl+Shift+P`(for windows/linux) or `Cmd+Shift+P`(for mac) and select the option `Dev Containers: Rebuild and Reopen in Container`. This will open the current repository in a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) using Docker and will install all the requirements to run the example application.
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
