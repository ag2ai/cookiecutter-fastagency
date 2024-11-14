#!/bin/bash


# Check file registered_app_domain.txt exists. If it does, echo and exit.
if [ -f registered_app_domain.txt ]; then
    echo -e "\033[1;33mWarning: App name is already registered.\033[0m"
    echo -e "\033[0;32mRegistered app name is:\033[0m"
    cat registered_app_domain.txt
    exit 1
fi

echo -e "\033[0;32mLogging into fly.io\033[0m"
fly auth login

export FLY_APP_NAME={{ cookiecutter.project_slug.replace("_", "-") }}

echo -e "\033[0;32mRegistering app name in fly.io\033[0m"
if fly apps create $FLY_APP_NAME; then
    echo "$FLY_APP_NAME.fly.dev" > registered_app_domain.txt
    echo -e "\033[0;32mApp name registered successfully\033[0m"
    echo -e "\033[0;32mRegistered app name is:\033[0m"
    cat registered_app_domain.txt
else
    echo -e "\033[1;31mError: App name is not available.\033[0m"
    echo -e "\033[1;31mPlease change the app name in fly.toml and scripts/register_to_fly_io.sh and run this script again.\033[0m"
    exit 1
fi
