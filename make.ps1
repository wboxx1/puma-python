
###################3
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$command
)

$Script:BROWSER_PYSCRIPT = "
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open(""file://"" + pathname2url(os.path.abspath(sys.argv[1])))
"
$Script:PRINT_HELP_PYSCRIPT = "
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print(""%-20s %s"" % (target, help))
"

function help() {
    Get-Help -Name "make"
#	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)
}

<#
.Description
Make file for puma-python
#>
function make($command) {

}

<#
.Description
Remove all build, test, coverage and Python artifacts
#>
function clean() {
    cleanBuild
    cleanPyc
    cleanTest
}

<#
.Description
Remove build artifacts
#>
function cleanBuild() {
    Remove-Item ".\build" -Recurse
    Remove-Item ".\dist" -Recurse
    Remove-Item ".\.eggs" -Recurse
    Remove-Item ".\*.egg-info"
    Remove-Item ".\*.egg"
}

<#
.Description
Remove Python file artifacts
#>
function cleanPyc() {
    Remove-Item ".\*.pyc"
    Remove-Item ".\*.pyo"
    Remove-Item ".\*~"
    Remove-Item ".\__pycache__" -Recurse
}

<#
.Description
Remove test and coverage artifacts
#>
function cleanTest() {
    Remove-Item ".\.tox" -Recurse -Force
    Remove-Item ".\.coverage" -Force
    Remove-Item ".\.htmlcov" -Recurse -Force
    Remove-Item ".\.pytest_cache" -Recurse -Force
}

<#
.Description
Check style with flake8
#>
function lint() {
    Invoke-Expression "flake8 puma_python tests"
}

<#
.Description
Run tests quickly with the default Python
#>
function test() {
    Invoke-Expression "poetry run pytest .\tests"
}

<#
.Description
Run tests on every Python version with tox
#>
function testAll() {
    Invoke-Expression "tox"
}

<#
.Description
Check code coverage quickly with the default Python
#>
function coverage() {
    Invoke-Expression "poetry run coverage run --source src/puma_python -m pytest"
    Invoke-Expression "poetry coverage report -m"
    Invoke-Expression "poetry coverage html"
    Invoke-Expression "poetry run python -c ""$Script:BROWSER_PYSCRIPT"" htmlcov/index.html"
}

<#
Generate Sphinx HTML documentation, including API docs
#>
function docs(){
    Remove-Item ".\docs\puma_python.rst" -Force
    Remove-Item ".\docs\modules.rst" -Force
    Invoke-Expression "poetry run sphinx-apidoc -o docs\ src\puma_python"
    Invoke-Expression "cd .\docs && poetry run make clean && poetry run make html"
    Invoke-Expression "poetry run ""$Script:BROWSER_PYSCRIPT"" docs\_build\html\index.html"
}

<#
Compile the docs watching for changes
#>
function servedocs() {
    docs
    Invoke-Expression "poetry run watchmedo shell-command -p '*.rst' -c 'cd .\docs && make html' -R -D"
}

<#
Package and upload a release
#>
function release() {
    dist
    Invoke-Expression "poetry publish"

}

<#
Builds source and wheel package
#>
function dist() {
    clean
    Invoke-Expression "poetry build"
}

<#
Install the package to the active Python's site-packages
#>
function install() {
    clean
    Invoke-Expression "poetry install"
}

function bumpversionMajor {
    $ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
    $bumpVersion = Join-Path $ScriptDir powerBump.ps1
    # Import-Module $bumpVersion
    Invoke-Expression "$bumpVersion major"
}

function bumpversionMinor {
    $ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
    $bumpVersion = Join-Path $ScriptDir powerBump.ps1
    # Import-Module $bumpVersion
    Invoke-Expression "$bumpVersion minor"
}

function bumpversionPatch {
    $ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
    $bumpVersion = Join-Path $ScriptDir powerBump.ps1
    # Import-Module $bumpVersion
    Invoke-Expression "$bumpVersion patch"
}
    
switch ($command) {
    install { install; break }
    dist { dist; break }
    release { release; break }
    servedocs { servedocs; break }
    docs { docs; break }
    coverage { coverage; break }
    test { test; break }
    test-all { testAll; break }
    lint { lint; break }
    clean-test { cleanTest; break }
    clean-pyc { cleanPyc; break }
    clean-build { cleanBuild; break }
    clean { clean; break }
    help { help; break }
    bumpversion-major { bumpversionMajor; break }
    bumpversion-minor { bumpversionMinor; break }
    bumpversion-patch { bumpversionPatch; break }
    Default {}
}