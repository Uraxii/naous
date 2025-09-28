# Naous Python Server

## Installing Requirements

1. Create a virtual environment

Enter `.../naous/server`directory and run `python -m venv --prompt naous venv`

2. Start the virtual environment by running the activation scripts.

**Windows**
`./venv/bin/activate.ps1`
**Linux**
`source ./venv/bin/activate`

3. Start the server

Enter `.../naoud/server/server` directory and run `uvicorn app:app --reload`

4. Stop the server by pressing `Ctrl+C`

5. Exit the virtual environment by typing `deactivate`
