#!/usr/bin/env bash
set -e

echo "Running mypy..."
mypy

echo "Running bandit..."
bandit -c pyproject.toml -r {{cookiecutter.project_slug}}

echo "Running semgrep..."
semgrep scan --config auto --error
