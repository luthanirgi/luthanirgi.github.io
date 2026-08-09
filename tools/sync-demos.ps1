# Copies the built NUI of the playable resources into docs/demos/, which is what the resource pages
# embed in an iframe.
#
# Wipe-and-copy rather than merge: Vite puts a content hash in every asset filename, so a rebuild
# writes index-<newhash>.js next to the old one. Merging would leave every past bundle in the repo
# forever, a couple of hundred KB at a time.
#
# Paths are handled with -LiteralPath throughout because this tree lives under D:\[Jualan]\[Script],
# and PowerShell reads [ ] in a normal -Path as a character-class wildcard that matches nothing.
param(
    # Where the mi resources are checked out. Default assumes it sits next to this repo.
    [string]$Source = (Join-Path $PSScriptRoot '..\..\mi-project')
)

$ErrorActionPreference = 'Stop'

$demoRoot = Join-Path $PSScriptRoot '..\docs\demos'
$names = @('mi_minigame', 'mi_coopminigames')

# .NET rather than New-Item: New-Item has no -LiteralPath in Windows PowerShell 5.1, and its -Path
# would take the [ ] in this tree as a wildcard.
[void][System.IO.Directory]::CreateDirectory($demoRoot)

foreach ($name in $names) {
    $from = Join-Path $Source "$name\web\build"
    $to = Join-Path $demoRoot $name

    if (-not (Test-Path -LiteralPath $from)) {
        throw "no build at $from - run 'npm --prefix $name/web run build' first"
    }

    if (Test-Path -LiteralPath $to) { Remove-Item -LiteralPath $to -Recurse -Force }
    Copy-Item -LiteralPath $from -Destination $to -Recurse -Force

    $kb = [math]::Round((Get-ChildItem -LiteralPath $to -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB)
    Write-Host "$name -> docs/demos/$name  ($kb KB)"
}

Write-Host ''
Write-Host 'Done. Check them with:  python -m mkdocs serve'
