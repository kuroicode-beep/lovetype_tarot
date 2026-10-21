# tools/build_store_candidate.ps1
param([string]$DefinesPath = 'build/release_config/defines.json')
$ErrorActionPreference = 'Stop'
if (!(Test-Path -LiteralPath $DefinesPath)) { throw 'Google OAuth 빌드 설정 파일이 필요합니다. docs/reports/완료보고_20261021_출시차단수정_코덱스.md 참조' }
$defines = Get-Content -LiteralPath $DefinesPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (!$defines.GOOGLE_WEB_CLIENT_ID -or !$defines.API_BASE_URL) { throw 'GOOGLE_WEB_CLIENT_ID와 API_BASE_URL이 필요합니다.' }
flutter build appbundle --release "--dart-define-from-file=$DefinesPath"
if ($LASTEXITCODE -ne 0) { throw 'Android AAB 빌드 실패' }
$bundle = Get-Item -LiteralPath 'build/app/outputs/bundle/release/app-release.aab'
if ($bundle.Length -le 0) { throw 'Android AAB가 비어 있습니다.' }
Get-FileHash -LiteralPath $bundle.FullName -Algorithm SHA256
