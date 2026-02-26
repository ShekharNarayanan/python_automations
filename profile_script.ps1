function open {
    param(
        [string]$name,
        [string]$scope
    )

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host "Usage: open <project_name> [work|personal]"
        return
    }

    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = 'work' }
    if ($scope -ne 'work' -and $scope -ne 'personal') {
        Write-Host "Scope must be: work or personal"
        return
    }

    $root = "C:\Users\narayana\projects"
    $project = if ($scope -eq 'personal') { Join-Path (Join-Path $root 'personal') $name } else { Join-Path $root $name }

    if (!(Test-Path $project)) {
        Write-Host "No such project: $project"
        return
    }

    code $project
    Start-Process cmd -ArgumentList '/k', "cd /d `"$project`" && if exist .venv\Scripts\activate.bat call .venv\Scripts\activate.bat"
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

    if ([string]::IsNullOrWhiteSpace($scope)) { $scope = 'work' }
    if ($scope -ne 'work' -and $scope -ne 'personal') {
        Write-Host "Scope must be: work or personal"
        return
    }

    $root = "C:\Users\narayana\projects"
    $base = if ($scope -eq 'personal') { Join-Path $root 'personal' } else { $root }
    $proj = Join-Path $base $name

    # ensure base exists (esp. personal/)
    New-Item -ItemType Directory -Force -Path $base | Out-Null

    if (Test-Path $proj) {
        Write-Host "Project already exists at $proj"
        open $name $scope
        return
    }

    New-Item -ItemType Directory -Force -Path $proj | Out-Null
    Set-Location $proj

    uv init
    uv venv

    open $name $scope
    Write-Host "Created $scope project at $proj"
}