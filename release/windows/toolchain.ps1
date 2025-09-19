#!/usr/bin/env pwsh

$global:CompilerFlags = @(
    '/FS'
)

$global:LinkerFlags = @(
    '/LTCG'
    '/INCREMENTAL:NO'
    '/OPT:REF'
    '/DEBUG'
    '/PDBALTPATH:%_PDB%'
)

$global:VsInstallPrefix = Join-Path ${env:ProgramFiles} 'Microsoft Visual Studio\2022\Community'
$global:VswherePath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$global:VcVarsScript = Join-Path $VsInstallPrefix 'VC\Auxiliary\Build\vcvarsall.bat'

# Use vswhere to get the semantic version (strip anything after '+')
$global:VsVersion = (& $VswherePath -Property catalog_productSemanticVersion -Path $VsInstallPrefix) -split '\+' | Select-Object -First 1

