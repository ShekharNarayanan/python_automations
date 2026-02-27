# tests/project-tools.Tests.ps1
# Pester v5+
# Creates a per-run temp config.json next to project-tools.ps1 (and restores yours after).
# Does NOT use or create tests/dummy_config.json.
# Imports project-tools.ps1 inside Describe so mocks apply in CI.

BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:Repo = Split-Path -Parent $script:Here

    # Paths
    $script:ScriptPath = Join-Path $script:Repo "project-tools.ps1"
    $script:CfgTarget  = Join-Path (Split-Path $script:ScriptPath -Parent) "config.json"
    $script:CfgBackup  = "$script:CfgTarget.bak"

    # Unique temp root for this test run
    $script:TmpRoot = Join-Path $env:TEMP ("projtools_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $script:TmpRoot | Out-Null

    # Backup real config.json if present
    $script:HadOriginalCfg = Test-Path $script:CfgTarget
    if ($script:HadOriginalCfg) {
        Copy-Item $script:CfgTarget $script:CfgBackup -Force
    }

    # Write per-run dummy config.json next to the script under test
    $cfg = @{
        vscode_command    = "code"
        work_subdir       = "work"
        personal_subdir   = "personal"
        default_scope     = "work"
        root              = $script:TmpRoot
        venv_activate_cmd = "dummy\act.bat"
    } | ConvertTo-Json -Depth 10

    Set-Content -Path $script:CfgTarget -Value $cfg -Encoding UTF8
}

AfterAll {
    # Restore original config.json (or remove the temp one if none existed)
    if (Test-Path $script:CfgBackup) {
        Move-Item $script:CfgBackup $script:CfgTarget -Force
    } elseif (Test-Path $script:CfgTarget) {
        Remove-Item $script:CfgTarget -Force
    }

    # Clean temp workspace
    if (Test-Path $script:TmpRoot) {
        Remove-Item -Recurse -Force $script:TmpRoot
    }
}

Describe "project-tools.ps1" {

    BeforeAll {
        # Import script under test (it will load config.json next to it)
        . $script:ScriptPath
    }

    BeforeEach {
        # Prevent any real side effects
        Mock -CommandName uv -MockWith { }
        Mock Start-Process { }
        Mock -CommandName code { }
    }

    It "Resolve-ProjectPath defaults to work scope when omitted" {
        $p = Resolve-ProjectPath "abc" ""
        $p | Should -Be (Join-Path (Join-Path $script:TmpRoot "work") "abc")
    }

    It "Resolve-ProjectPath supports personal scope" {
        $p = Resolve-ProjectPath "abc" "personal"
        $p | Should -Be (Join-Path (Join-Path $script:TmpRoot "personal") "abc")
    }

    It "make new_project creates folder, calls uv init + uv venv, and launches editor + cmd" {
        make new_project "myproj" "work"

        $proj = Join-Path (Join-Path $script:TmpRoot "work") "myproj"
        Test-Path $proj | Should -BeTrue

        Assert-MockCalled uv -Times 2
        Assert-MockCalled code -Times 1
        Assert-MockCalled Start-Process -Times 1
    }

    It "open refuses when project does not exist" {
        open "does_not_exist" "work" | Out-Null
        Assert-MockCalled Start-Process -Times 0
    }

    It "open with git-pull triggers git-pull cmd construction (without actually running git)" {
        # Create a fake project folder with a .git dir so the 'if exist .git' branch is meaningful
        $proj = Join-Path (Join-Path $script:TmpRoot "work") "pullproj"
        New-Item -ItemType Directory -Force -Path (Join-Path $proj ".git") | Out-Null

        open "pullproj" "work" "git-pull"

        Assert-MockCalled code -Times 1
        Assert-MockCalled Start-Process -Times 1
    }
}