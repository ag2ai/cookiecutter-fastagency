#!/bin/bash

# This script is used to test the cookiecutter template
# It will create a new project using the cookiecutter template under the generated/ directory
# The script accepts two positional arguments: app-type and python-version
# The cookiecutter replay file is used to provide the default values for the cookiecutter template

# Accept two arguments: app-type and python-version
echo "Generating project using cookiecutter template with app-type: $1 and python-version: $2"
cookiecutter -f --replay-file ./cookiecutter_replay/$1_$2.json --output-dir generated/ ./ 

# Install generated project's dependencies
echo "Installing dependencies for the generated project"
cd generated/my_fastagency_app && pip install -e .[dev] && cd ../../

# Initialize git in the generated project(needed for pre-commit)
echo "Initializing git in the generated project"
cd generated/my_fastagency_app && git init && git add . && cd ../../

# Run pre-commit
echo "Running pre-commit"
cd generated/my_fastagency_app && pre-commit run --show-diff-on-failure --color=always --all-files && cd ../../
