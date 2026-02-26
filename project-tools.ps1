# project-tools.ps1
# Repo-first config + commands:
#   make new_project <name> [work|personal]
#   open <name> [work|personal] [pull]
#
# Config file must live next to this script: $PSScriptRoot\config.json

# --- Load config once (on import) ---
$script:CfgPath = Join-Path $PSScriptRoot "config.json"
if (!(Test-Path $script:CfgPath)) {
    throw "Missing config.json next to project-tools.ps1. Expected: $script:CfgPath"
}
$script:Cfg = Get-Content $script:CfgPath -Raw | ConvertFrom-Json


function Resolve-ProjectPath {
    param(
        [Parameter(Mandatory = $true)][string]$name,
        [string]$scope
    )

    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = $script:Cfg.default_scope }
    if ($scope -ne 'work' -and $scope -ne 'personal') { throw "Scope must be: work or personal" }

    $root = [Environment]::ExpandEnvironmentVariables($script:Cfg.root)
    $workSubdir = $script:Cfg.work_subdir
    $personalSubdir = $script:Cfg.personal_subdir

    $base =
        if ($scope -eq 'work')     { Join-Path $root $workSubdir }
        else                      { Join-Path $root $personalSubdir }

    return (Join-Path $base $name)
}

function open {
    param(
        [string]$name,
        [string]$scope,
        [string]$action
    )

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host "Usage: open <project_name> [work|personal] [pull]"
        return
    }

    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = $script:Cfg.default_scope }

    $project = Resolve-ProjectPath $name $scope

    if (!(Test-Path $project)) {
        Write-Host "No such project: $project"
        return
    }

    # Optional: git pull
    if ($action -eq "pull") {
        if (Test-Path (Join-Path $project ".git")) {
            if (Get-Command git -ErrorAction SilentlyContinue) {
                Push-Location $project
                git pull
                Pop-Location
            } else {
                Write-Host "git not found on PATH."
            }
        } else {
            Write-Host "Not a git repository: $project"
        }
    }

    # VS Code
    & $script:Cfg.vscode_command $project | Out-Null

    # CMD + activate venv (if it exists)
    $activate = $script:Cfg.venv_activate_cmd
    $cmd = "cd /d `"$project`" && if exist `"$activate`" call `"$activate`""
    Start-Process cmd -ArgumentList '/k', $cmd
}

function make {
    param(
        [string]$cmd,
        [string]$name,
        [string]$scope
    )

    if ($cmd -ne 'new_project' -or [string]::IsNullOrWhiteSpace($name)) {
        Write-Host "Usage: make new_project <project_name> [work|personal]"
        return
    }

    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = $script:Cfg.default_scope }

    $proj = Resolve-ProjectPath $name $scope
    $base = Split-Path $proj -Parent

    # Ensure base exists (esp. personal subdir)
    New-Item -ItemType Directory -Force -Path $base | Out-Null

    if (Test-Path $proj) {
        Write-Host "Project already exists at $proj"
        open $name $scope
        return
    }

    New-Item -ItemType Directory -Force -Path $proj | Out-Null

    Push-Location $proj
    uv init
    uv venv
    Pop-Location

    open $name $scope
    Write-Host "Created $scope project at $proj"
}