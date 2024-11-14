#!/bin/bash

# Check file registered_app_domain.txt exists. If it does not exists, echo and exit.
if [ ! -f registered_app_domain.txt ]; then
  echo -e "\033[0;31mError: App name is not registered.\033[0m"
  echo -e "\033[0;31mRegister your app name by running the script 'scripts/register_to_fly_io.sh'.\033[0m"
  echo -e "\033[0;31mExiting.\033[0m"
  exit 1
fi

echo -e "\033[0;32mLogging into fly.io\033[0m"
fly auth login

echo -e "\033[0;32mDeploying to fly.io\033[0m"
fly deploy --config fly.toml --yes
fly scale count 1 --config fly.toml --yes

echo -e "\033[0;32mSetting secrets\033[0m"
fly secrets set OPENAI_API_KEY=$OPENAI_API_KEY
