# project-tools.ps1
# Loads config from $HOME\.project_tools.json (bootstraps from repo's project-tools.json if missing)
# Provides: make, open

function Get-ProjectToolsConfig {
    $homeCfg = Join-Path $HOME ".project_tools.json"

    if (!(Test-Path $homeCfg)) {
        $repoCfg = Join-Path $PSScriptRoot "project-tools.json"
        if (Test-Path $repoCfg) {
            Copy-Item -Force $repoCfg $homeCfg
            Write-Host "Created config at $homeCfg (copied from repo). Update paths inside it."
        } else {
            throw "Missing config. Create $homeCfg (and/or add project-tools.json next to project-tools.ps1)."
        }
    }

    return (Get-Content $homeCfg -Raw | ConvertFrom-Json)
}

function Resolve-ProjectPath {
    param([Parameter(Mandatory=$true)][string]$name, [string]$scope)

    $cfg = Get-ProjectToolsConfig

    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = $cfg.default_scope }
    if ($scope -ne 'work' -and $scope -ne 'personal') { throw "Scope must be: work or personal" }

    $root = $cfg.root
    $personalSubdir = $cfg.personal_subdir

    if ($scope -eq 'personal') {
        return (Join-Path (Join-Path $root $personalSubdir) $name)
    } else {
        return (Join-Path $root $name)
    }
}

function open {
    param(
        [string]$name,
        [string]$scope
    )

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host "Usage: open <project_name> [work|personal]"
        return
    }

    $cfg = Get-ProjectToolsConfig
    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = $cfg.default_scope }

    $project = Resolve-ProjectPath $name $scope
    if (!(Test-Path $project)) {
        Write-Host "No such project: $project"
        return
    }

    # VS Code
    & $cfg.vscode_command $project | Out-Null

    # CMD + activate venv (if it exists)
    $activate = $cfg.venv_activate_cmd
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

    $cfg = Get-ProjectToolsConfig
    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = $cfg.default_scope }

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