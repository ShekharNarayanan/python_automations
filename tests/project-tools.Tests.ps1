# tests/project-tools.Tests.ps1
# Pester v5+
# - Creates per-run config.json next to project-tools.ps1 (restores after)
# - Stubs external commands (uv, code) as PS functions (reliable in CI)
# - Mocks Start-Process to avoid opening cmd

BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:Repo = Split-Path -Parent $script:Here

    $script:ScriptPath = Join-Path $script:Repo "project-tools.ps1"
    $script:CfgTarget  = Join-Path (Split-Path $script:ScriptPath -Parent) "config.json"
    $script:CfgBackup  = "$script:CfgTarget.bak"

    $script:TmpRoot = Join-Path $env:TEMP ("projtools_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $script:TmpRoot | Out-Null

    if (Test-Path $script:CfgTarget) {
        Copy-Item $script:CfgTarget $script:CfgBackup -Force
    }

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
    if (Test-Path $script:CfgBackup) {
        Move-Item $script:CfgBackup $script:CfgTarget -Force
    } elseif (Test-Path $script:CfgTarget) {
        Remove-Item $script:CfgTarget -Force
    }

    if (Test-Path $script:TmpRoot) {
        Remove-Item -Recurse -Force $script:TmpRoot
    }
}

Describe "project-tools.ps1" {

    BeforeAll {
        # Call counters
        $script:UvCalls = 0
        $script:CodeCalls = 0

        # Stub external commands as functions (these will resolve before any exe)
        function global:uv {
            param([Parameter(ValueFromRemainingArguments=$true)] $args)
            $script:UvCalls++
        }

        function global:code {
            param([Parameter(ValueFromRemainingArguments=$true)] $args)
            $script:CodeCalls++
        }

        . $script:ScriptPath
    }

    AfterAll {
        # Cleanup stubs (avoid polluting session)
        Remove-Item function:\uv   -ErrorAction SilentlyContinue
        Remove-Item function:\code -ErrorAction SilentlyContinue
    }

    BeforeEach {
        Mock Start-Process { }  # don’t open cmd
    }

    It "Resolve-ProjectPath defaults to work scope when omitted" {
        $p = Resolve-ProjectPath "abc" ""
        $p | Should -Be (Join-Path (Join-Path $script:TmpRoot "work") "abc")
    }

    It "Resolve-ProjectPath supports personal scope" {
        $p = Resolve-ProjectPath "abc" "personal"
        $p | Should -Be (Join-Path (Join-Path $script:TmpRoot "personal") "abc")
    }

    It "make new_project creates folder and triggers uv+code+Start-Process" {
        $script:UvCalls = 0
        $script:CodeCalls = 0

        make new_project "myproj" "work"

        $proj = Join-Path (Join-Path $script:TmpRoot "work") "myproj"
        Test-Path $proj | Should -BeTrue

        $script:UvCalls   | Should -Be 2
        $script:CodeCalls | Should -Be 1
        Assert-MockCalled Start-Process -Times 1
    }

    It "open refuses when project does not exist" {
        $script:CodeCalls = 0

        open "does_not_exist" "work" | Out-Null

        $script:CodeCalls | Should -Be 0
        Assert-MockCalled Start-Process -Times 0
    }

    It "open with git-pull launches editor + cmd (without running git)" {
        $script:CodeCalls = 0

        $proj = Join-Path (Join-Path $script:TmpRoot "work") "pullproj"
        New-Item -ItemType Directory -Force -Path (Join-Path $proj ".git") | Out-Null

        open "pullproj" "work" "git-pull"

        $script:CodeCalls | Should -Be 1
        Assert-MockCalled Start-Process -Times 1
    }
}