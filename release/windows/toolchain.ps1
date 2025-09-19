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

foreach ($VsType in 'Enterprise','Professional','Community','BuildTools') {

    # Try x86 Program Files first, then 64-bit Program Files
    $roots = @(${env:ProgramFiles(x86)}, ${env:ProgramFiles})

    foreach ($root in $roots) {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            # PS 6+/7+: can use -AdditionalChildPath
            $candidate = Join-Path -Path $root `
                                   -ChildPath 'Microsoft Visual Studio' `
                                   -AdditionalChildPath '2022', $VsType
        } else {
            # PS 5.1: nest Join-Path
            $candidate = Join-Path (Join-Path (Join-Path $root 'Microsoft Visual Studio') '2022') $VsType
        }

        if (Test-Path $candidate) {
            $global:VsInstallPrefix = $candidate
            break
        }
    }

    if ($global:VsInstallPrefix) { break }
}

if (-not $global:VsInstallPrefix) {
    throw "Visual Studio 2022 not found in Program Files or Program Files (x86)."
}
# Build path to vswhere.exe
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $VswherePath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Microsoft Visual Studio' -AdditionalChildPath 'Installer','vswhere.exe'
} else {
    $VswherePath = Join-Path (Join-Path (Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio') 'Installer') 'vswhere.exe'
}

# Use vswhere to get the semantic version (strip anything after '+')
$global:VsVersion = (& $VswherePath -Property catalog_productSemanticVersion -Path $VsInstallPrefix) -split '\+' | Select-Object -First 1

# Build path to vcvarsall.bat under the selected VS install
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $global:VcVarsScript = Join-Path -Path $VsInstallPrefix -ChildPath 'VC' -AdditionalChildPath 'Auxiliary','Build','vcvarsall.bat'
} else {
    $global:VcVarsScript = Join-Path (Join-Path (Join-Path (Join-Path $VsInstallPrefix 'VC') 'Auxiliary') 'Build') 'vcvarsall.bat'
}
