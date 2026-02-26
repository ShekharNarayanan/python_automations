# Python automations: 
**NOTE**: Currently only working for a Windows x VSCODE + UV setup

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExOTE3eWEyYWczbmZyZWp4MWZ4ZGY5a2RuYnBhcmxoZjU3dndocjNhYSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/26ufnwz3wDUli7GU0/giphy.gif" width="400" />

**This repository is for 🌟**you**🌟 if**:

1. You find yourself juggling multiple python projects at work and want to build on some personal ones too. Basically: several projects, each requiring the same set of setup steps. 

2. You don't want to compromise on best software development practices even for smaller projects. Think of reduced technical debt **right away**.

3. You want to automate. Right now.

4. You're cool and like to work with the terminal 😎

**Pain point** : 
Everytime I want to create a new python project or I wanna get back to an existing project I:
```
1.  Open terminal
2.  Navigate to some buried folder
3.  `cd` into project
4.  Create project tree
5.  Create virtual env
6.  Activate virtual environment
```

**AND THEN**  
1. `Open VS Code`

**No more. This repo lets you turn on your computer and get to work in a structured way in less than a minute.**

------------------------------------------------------------------------
# What This Does

Adds two simple commands to PowerShell:

1. `Make new_project`
```powershell
make new_project <name> [work|personal]
```

This automatically:

-   Creates the correct folder based on paths you predefine
-   Runs `uv init` - **Initialize project tree**
-   Runs `uv venv` - **Make environment**
-   Opens VS Code - **Your editor is open with your project folder**
-   Opens CMD with the virtual environment activated - **Your're ready for  `python -m main` in seconds. Every time.**

2. `open project`
```powershell
open <name> [work|personal]
```

This automatically:

-   Opens VS Code
-   Opens CMD
-   Activates `.venv` if it exists


------------------------------------------------------------------------
# Installation:

## 1. VS Code

1. Install Visual Studio Code installed.

2. Make the `code` command available in your terminal. Open VS Code → press `Ctrl + Shift + P` → run:
Shell Command: Install 'code' command in PATH

3. To verify, open powershell and paste the following:

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
git clone https://github.com/ShekharNarayanan/python_automations.git
```

------------------------------------------------------------------------

## 2) Modify the config file

Open config.json and set paths as you want to. Your config defines a root directory, for example:

    C:\Users\<you>\projects

Then new projects are created inside either the `work` or `personal` folder. Default is `work`. Feel free to change this to whatever suits you best.:

-   `work` → `C:\Users\<you>\projects\work\<project>`
-   `personal` → `C:\Users\<you>\projects\personal\<project>`


Example:

``` json
{
  "root": "%USERPROFILE%/projects",
  "work_subdir": "work",
  "personal_subdir": "personal",
  "default_scope": "work",
  "vscode_command": "code",
  "venv_activate_cmd": ".venv/Scripts/activate.bat"
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

In your file explorer, copy the complete path to the repository and paste it in your profile script as such:

``` powershell
. "C:\Users\narayana\projects\personal\python_automations\project-tools.ps1"
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
------------------------------------------------------------------------

### Open an existing python project

``` powershell
open api work
```

OR
```
open side_hustle personal
```
------------------------------------------------------------------------

# Updating

When the repo changes:

``` powershell
cd <repo_path>
git pull
```

No profile changes required.

------------------------------------------------------------------------



