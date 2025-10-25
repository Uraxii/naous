# Naous Python Server

## Summary

This install guide assumes you have already cloned the repo and have a local copy of the files. If you have not already done so, please go do that first and then return here to proceed with server setup.

In order to run the Python server for Naous, you will generally need to do the steps below. Read the info further down this document for details.

1. Install Python (v3.13.9)
2. Install the virtual environment
3. Enter the environment and install dependencies via pip
4. Run the server (while still in the environment)

See this wiki page for images and even more details: <https://github.com/Uraxii/naous/wiki/Installing-Naous-Python-Server>

## Quick Setup

If you just want the commands without the fluff, follow these steps:

1. Install Python v3.13.*
2. From the `godot/server` directory, run: `python -m venv --prompt naous venv`
3. Run the venv activate script: Windows=`./venv/Scripts/Activate.ps1` | Linux=`source ./venv/bin/activate`
4. Install dependencies by running: `pip install -r requirements.txt`
5. Change directory to `godot/server/server` and run: `uvicorn app:app --reload`
6. When you want to stop running the server, use `Ctrl+C` to stop it running. You can also exit the venv by running: `deactivate`

## Install Python

You will specifically want a 3.13.* version of Python to run the server. At time of writing, 3.13.9 is the most recent stable release.

> Windows

You can download the installer from here and run it like any other executable

- [Download Python for Windows](https://www.python.org/downloads/windows/)

> Linux

You can use `brew` to install Python with a command like the following:

```brew install python@3.13.9```

## Install Steps

Note that your exact steps will vary slightly based on your OS platform of choice (Windows or Linux).

- Windows: PowerShell is recommended as your terminal.
- Linux: Your built-in bash terminal is recommend.

### 1. Create the virtual environment
  
  This will set up a localized context for running this server such that it won't rely on other programs on your computer. The purpose of this is to encapsulate everything the server needs all within the project itself so you won't have to worry about anything outside of the project breaking things.

- Enter the `godot/server`directory and run:

```bash
python -m venv --prompt naous venv
```

### 2. Start the virtual environment

   This will "enter" the virtual environment. While your terminal runs in this context, it will use the systems locally installed to this project.

   Run the appropriate command below and your terminal prompt should now start with the text `(naous)`

> Windows

   ```PowerShell
   ./venv/Scripts/Activate.ps1
   ```

> Linux

   ```bash
   source ./venv/bin/activate
   ```

### 3. Install the dependencies using `pip`

   The project repo already includes a `requirements.txt` file that defines the dependencides. Now we just need to use `pip` to read that file and install what's defined in there. By doing this while inside the virtual environment, the installation will be independently attached to this project via the virtual environment.

   From the `godot/server/` directory while in the virtual environment:

   ```bash
   pip install -r requirements.txt
   ```

## Running the server

- Enter the virtual environment as described above via the `activate` script.

- Start the server by changing your directory to `godot/server/server` and then run `uvicorn app:app --reload`.

- Stop the server by pressing `Ctrl+C`.

- Exit the virtual environment by typing `deactivate`.
