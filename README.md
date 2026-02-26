# Project Tools (PowerShell)

Automate project creation and opening with uv + VS Code.

Provides two commands:

-   `make new_project <name> [work|personal]`
-   `open <name> [work|personal]`

------------------------------------------------------------------------

## Scope Behavior

-   **work** → `<root>\<project_name>`
-   **personal** → `<root>\<personal_subdir>\<project_name>`

Defaults are defined in the config file.

------------------------------------------------------------------------

## Requirements

-   Python installed
-   `uv` installed and on PATH
-   VS Code installed
-   `code` CLI available on PATH\
    (VS Code → Command Palette → *Shell Command: Install 'code' command
    in PATH*)

------------------------------------------------------------------------

## Installation

### 1. Allow PowerShell profile execution

Run once:

``` powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

------------------------------------------------------------------------

### 2. Clone the repository

``` powershell
git clone <REPO_URL> C:\some\path\project-tools
```

------------------------------------------------------------------------

### 3. Add profile loader

Open your PowerShell profile:

``` powershell
notepad $PROFILE
```

If the file does not exist, create it:

``` powersshell
New-Item -ItemType File -Force -Path $PROFILE
notepad $PROFILE
```

Add this line to your profile:

``` powershell
$cfg = Get-Content "$HOME\.project_tools.json" -Raw | ConvertFrom-Json
. (Join-Path $cfg.repo_path "project-tools.ps1")
```

Save and restart PowerShell.

------------------------------------------------------------------------

### 4. Configure paths

Open this file:

    C:\Users\<your_user>\.project_tools.json

Example:

``` json
{
  "repo_path": "C:\\some\\path\\project-tools",
  "root": "C:\\Users\\<your_user>\\projects",
  "personal_subdir": "personal",
  "default_scope": "work",
  "vscode_command": "code",
  "venv_activate_cmd": ".venv\\Scripts\\activate.bat"
}
```

Update paths accordingly.

------------------------------------------------------------------------

## Usage

Create a new project:

``` powershell
make new_project myapp work
make new_project sideproject personal
```

Open an existing project:

``` powershell
open myapp work
open sideproject personal
```

------------------------------------------------------------------------

## What Happens

`make` will:

-   Create the directory in the correct scope
-   Run `uv init`
-   Run `uv venv`
-   Open VS Code
-   Open CMD with the virtual environment activated

`open` will:

-   Open VS Code
-   Open CMD in the project directory
-   Activate `.venv` if it exists

------------------------------------------------------------------------

## Updating

To update the tool:

``` powershell
cd <repo_path>
git pull
```

No changes to your PowerShell profile required.

------------------------------------------------------------------------

## Notes

-   Default scope is controlled by `default_scope` in config.
-   All paths are centralized in `config.json`.
-   This keeps the PowerShell profile clean and portable.
