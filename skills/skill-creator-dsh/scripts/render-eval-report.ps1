param(
  [Parameter(Mandatory = $true)][string]$ResultsPath,
  [Parameter(Mandatory = $true)][string]$OutputPath,
  [string]$TemplatePath = (Join-Path $PSScriptRoot '..\templates\eval-report.html')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ResultsPath)) { throw "Results file not found: $ResultsPath" }
if (-not (Test-Path $TemplatePath)) { throw "Template file not found: $TemplatePath" }

$results = Get-Content -Raw -Encoding utf8 $ResultsPath | ConvertFrom-Json
$template = Get-Content -Raw -Encoding utf8 $TemplatePath

$marker = 'window.__EVAL_RESULTS__||{}'
if (-not $template.Contains($marker)) { throw "Template marker not found: $marker" }

$json = $results | ConvertTo-Json -Depth 30 -Compress
$json = $json.Replace('<', '\u003c').Replace('>', '\u003e').Replace('&', '\u0026')

$html = $template.Replace($marker, "window.__EVAL_RESULTS__=$json")

$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }

Set-Content -Encoding utf8 -Path $OutputPath -Value $html
Write-Output "Rendered $OutputPath"

# Escape-invariant checks: the embedded payload must not contain a raw script-close
# sequence or '<'/'&' that could break out of the inline script.
if ($html -match 'window\.__EVAL_RESULTS__=.*</script>') { throw "Embedded data contains a raw </script> sequence" }
if ($html -match 'window\.__EVAL_RESULTS__=.*<[^\\]') { throw "Embedded data contains an unescaped '<' character" }
if ($html -match 'window\.__EVAL_RESULTS__=.*&(?!amp;|lt;|gt;|quot;|#39;)') { throw "Embedded data contains an unescaped '&' character" }
Write-Output "Escaping invariants passed."
