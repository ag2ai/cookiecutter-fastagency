#!/bin/env bash

# This script is used to test the cookiecutter template
# It will create a new project using the cookiecutter template under the generated/$1-$2-$3/ directory
# The script accepts two positional arguments: app-type and python-version
# The cookiecutter replay file is used to provide the default values for the cookiecutter template

set -o errexit

# Accept two arguments: app-type and python-version
echo -e "\033[32mGenerating project using cookiecutter template with app-type: $1, python-version: $2 and authentication: $3\033[0m"
rm -rf generated/$1-$2-$3
cookiecutter -f --no-input --output-dir generated/$1-$2-$3/ ./ app_type=$1 python_version=$2 authentication=$3

# Install generated project's dependencies
echo -e "\033[32mInstalling dependencies for the generated project\033[0m"
cd generated/$1-$2-$3/my_fastagency_app && pip install -e .[dev] && cd ../../..

# Initialize git in the generated project(needed for pre-commit)
echo -e "\033[32mInitializing git in the generated project\033[0m"
cd generated/$1-$2-$3/my_fastagency_app && git init && git add . && cd ../../..
# uncomment this for debugging
# cd generated/$1-$2-$3/my_fastagency_app && git commit -m "init" --no-verify && cd ../../..

# Run pre-commit
echo -e "\033[32mRunning pre-commit\033[0m"
cd generated/$1-$2-$3/my_fastagency_app && pre-commit run --show-diff-on-failure --color=always --all-files && cd ../../..
