# {{cookiecutter.project_name}}

This repository contains a [`FastAgency`](https://github.com/airtai/fastagency) application which uses [NATS](https://nats.io/), [FastAPI](https://fastapi.tiangolo.com/), and [Mesop](https://google.github.io/mesop/). Below, you'll find a guide on how to run the application.

## Running FastAgency Application

To run this [`FastAgency`](https://github.com/airtai/fastagency) application, follow these steps:

1. Open this folder with [vscode](https://code.visualstudio.com/).

2. Open the `.devcontainer/devcontainer.env` file and set your `OPENAI_API_KEY`. Alternatively, you can skip this step and set the `OPENAI_API_KEY` later in the terminal of the devcontainer.

3. Press `Ctrl+Shift+P` or `Cmd+Shift+P` and select the option `Dev Containers: Rebuild and Reopen in Container`. This will open the current repository in a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) using Docker and will install all the requirements to run the example application.

4. The `1_main_natsprovider.py` file defines the autogen workflows and includes the `NatsAdapter` to exchange the workflow conversation as messages via NATS. In a devcontainer terminal, run the following command:

   ```bash
   uvicorn <project_name>.1_main_natsprovider:app --reload
   ```

5. The `2_main_fastapiprovider.py` file defines the `FastAPIAdapter`, which handles `NATS` messages using `NatsProvider`. In a new devcontainer terminal, run the following command:

   ```bash
   uvicorn <project_name>.2_main_fastapiprovider:app --host 0.0.0.0 --port 8008 --reload
   ```

6. Finally, the `3_main_mesop.py` file defines the `MesopUI`. In a new devcontainer terminal, run the following command to start the mesop UI:

   ```bash
   gunicorn <project_name>.3_main_mesop:app -b 0.0.0.0:8888 --reload
   ```

7. Open the Mesop UI URL [http://localhost:8888](http://localhost:8888) in your browser. You can now use the graphical user interface to start and run the autogen workflow defined in the `1_main_natsprovider.py` file.

## What's Next?

Once you’ve experimented with the default workflow in the Mesop UI, modify the autogen workflow to define your own workflows and try them out in the Mesop UI.
