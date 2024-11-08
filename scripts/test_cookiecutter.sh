#!/bin/bash

# This script is used to test the cookiecutter template
# It will create a new project using the cookiecutter template under the generated/ directory
# The script accepts two positional arguments: app-type and python-version
# The cookiecutter replay file is used to provide the default values for the cookiecutter template

# Accept two arguments: app-type and python-version
echo -e "\033[32mGenerating project using cookiecutter template with app-type: $1 and python-version: $2\033[0m"
cookiecutter -f --replay-file ./cookiecutter_replay/$1_$2.json --output-dir generated/ ./ 

# Install generated project's dependencies
echo -e "\033[32mInstalling dependencies for the generated project\033[0m"
cd generated/my_fastagency_app && pip install -e .[dev] && cd ../../

# Initialize git in the generated project(needed for pre-commit)
echo -e "\033[32mInitializing git in the generated project\033[0m"
cd generated/my_fastagency_app && git init && git add . && cd ../../

# Run pre-commit
echo -e "\033[32mRunning pre-commit\033[0m"
cd generated/my_fastagency_app && pre-commit run --show-diff-on-failure --color=always --all-files && cd ../../
