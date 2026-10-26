# scripts/verify.ps1: Windows PowerShell entry point for verify.sh
# Usage:
#   pwsh scripts/verify.ps1 fast
#   pwsh scripts/verify.ps1 full
#
# Delegates to scripts/verify.sh via Git Bash so checks remain identical across OSes.
# fast_checks: actionlint, yamllint .github examples fixtures, shellcheck scripts/*.sh, scripts/check-workflows.sh
# full_checks: fast + scripts/check-docs.sh, scripts/run-fixtures.sh (missing tools omitted: bats, markdownlint)
param([ValidateSet("fast", "full")][string]$Mode = "full")

$kitHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$kitBin = Join-Path $kitHome '.agent-team\bin'
if ((Test-Path $kitBin) -and ($env:Path -notlike "*$kitBin*")) { $env:Path = "$kitBin;$env:Path" }

$candidates = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, (Join-Path "$env:LOCALAPPDATA" "Programs")) |
  Where-Object { $_ } | ForEach-Object { Join-Path $_ "Git\bin\bash.exe" }
$bash = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $bash) {   # Git for Windows in a custom folder: <git>\cmd\git.exe -> <git>\bin\bash.exe
  $g = Get-Command git.exe -ErrorAction SilentlyContinue
  if ($g) { $c = Join-Path (Split-Path -Parent (Split-Path -Parent $g.Source)) "bin\bash.exe"; if (Test-Path $c) { $bash = $c } }
}
if (-not $bash) {
  $cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source -notlike "*\System32\*") { $bash = $cmd.Source }
}
if (-not $bash) { Write-Error "Git Bash not found. Install Git for Windows (https://git-scm.com/download/win)."; exit 1 }

& $bash (Join-Path $PSScriptRoot "verify.sh") $Mode
exit $LASTEXITCODE
