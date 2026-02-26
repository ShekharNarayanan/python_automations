# Windows automations ⚡

Because I got tired of doing this every single day:

1.  Open terminal\
2.  Navigate to some buried folder\
3.  `cd` into project\
4.  Open VS Code\
5.  Activate virtual environment

It's not hard.\
It's just repetitive.

And repetition is automation waiting to happen.

------------------------------------------------------------------------
## What This Does

Adds two simple commands to PowerShell:

``` powershell
make new_project <name> [work|personal]
open <name> [work|personal]
```

That's it.

No manual navigation.\
No remembering paths.\
No typing `cd` five times.

------------------------------------------------------------------------

## Why This Exists

If you create projects often, you know the friction:

-   Projects live in structured folders\
-   Some are work-related\
-   Some are personal\
-   Each needs a proper `uv` setup\
-   Each needs its own `.venv`\
-   Each needs VS Code\
-   Each needs activation

This tool removes all of that.

You think about the project.\
Not the filesystem.

------------------------------------------------------------------------
# Installation:

## 1. VS Code

You need Visual Studio Code installed.

You also need the `code` command available in your terminal.

Open VS Code → press `Ctrl + Shift + P` → run:

Shell Command: Install 'code' command in PATH

Then restart PowerShell.

Verify:

```powershell
code --version
```

## 2. UV

UV is a python dependency manager. It is fast (and awesome) and easy to configure.

Installation link: https://docs.astral.sh/uv/getting-started/installation/


# Configuring everything before usage 
------------------------------------------------------------------------

## 1) Clone the repo

``` powershell
git clone <REPO_URL> C:\some\path\project-tools
```

------------------------------------------------------------------------

## 2) Modify the config file
Open config.json and set paths as you want to. Your config defines a root directory, for example:

    C:\Users\<you>\projects

Then:

-   `work` → `C:\Users\<you>\projects\work\<project>`
-   `personal` → `C:\Users\<you>\projects\personal\<project>`


Example:

``` json
{
  "repo_path": "C:\\some\\path\\windows_automation", # path for repository
  "root": "C:\\Users\\<your_user>\\projects", # this is where you save your projects (work or personal)
  "personal_subdir": "personal",
  "default_scope": "work",
  "vscode_command": "code",
  "venv_activate_cmd": ".venv\\Scripts\\activate.bat"
}
```


------------------------------------------------------------------------

## 3) Allow PowerShell profiles

Run once:

``` powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

------------------------------------------------------------------------


## 5) Add loader to your PowerShell profile

Open your profile:

``` powershell
notepad $PROFILE
```

If it does not exist:

``` powershell
New-Item -ItemType File -Force -Path $PROFILE
notepad $PROFILE
```

Add this line:

``` powershell
$cfg = Get-Content "$HOME\.project_tools.json" -Raw | ConvertFrom-Json
. (Join-Path $cfg.repo_path "project-tools.ps1")
```

Save and restart PowerShell.


------------------------------------------------------------------------

# Usage 

### Creating a new python project

Open powershell and:

``` powershell
make new_project api work
```
OR 

```powershell
make new_project side_hustle personal
```

This automatically:

-   Creates the correct folder
-   Runs `uv init`
-   Runs `uv venv`
-   Opens VS Code
-   Opens CMD with the virtual environment activated

------------------------------------------------------------------------

### Open an existing python project

``` powershell
open api work
```

OR
```
open side_hustle personal
```

This:

-   Opens VS Code
-   Opens CMD
-   Activates `.venv` if it exists

------------------------------------------------------------------------

# Updating

When the repo changes:

``` powershell
cd <repo_path>
git pull
```

No profile changes required.

------------------------------------------------------------------------



