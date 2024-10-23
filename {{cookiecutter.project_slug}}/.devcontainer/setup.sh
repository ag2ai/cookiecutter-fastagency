# update pip
pip install --upgrade pip

# install dev packages
pip install -e ".[dev]"

# check OPENAI_API_KEY environment variable is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo
    echo -e "\033[33mWarning: OPENAI_API_KEY environment variable is not set.\033[0m"
    echo
fi
