param(
    [switch]$SkipFlutter,
    [switch]$SkipBundleCheck
)

$ErrorActionPreference = "Stop"

$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
    $failures.Add($Message) | Out-Null
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Add-WarningMessage([string]$Message) {
    $warnings.Add($Message) | Out-Null
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Add-Pass([string]$Message) {
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Require-File([string]$Path, [string]$Label) {
    if (Test-Path -LiteralPath $Path) {
        Add-Pass "$Label exists: $Path"
    } else {
        Add-Failure "$Label missing: $Path"
    }
}

function Require-Text([string]$Path, [string]$Pattern, [string]$Label) {
    if (!(Test-Path -LiteralPath $Path)) {
        Add-Failure "$Label cannot be checked because file is missing: $Path"
        return
    }

    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ($content -match $Pattern) {
        Add-Pass $Label
    } else {
        Add-Failure $Label
    }
}

function Invoke-CheckedCommand([string]$Label, [scriptblock]$Command) {
    Write-Host ""
    Write-Host "== $Label ==" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        Add-Failure "$Label failed with exit code $LASTEXITCODE"
    } else {
        Add-Pass "$Label completed"
    }
}

Write-Host "LoveType Tarot store readiness verification" -ForegroundColor Cyan
Write-Host "Root: $(Get-Location)"

Require-File "pubspec.yaml" "Flutter pubspec"
Require-File "android/app/build.gradle.kts" "Android Gradle config"
Require-File "android/key.properties.example" "Android signing example"
Require-File "docs/store-console-runbook-2026-06-28.md" "Store console runbook"
Require-File "docs/store-registration-completion-audit-2026-06-28.md" "Store completion audit"
Require-File "docs/privacy-policy-ko.md" "Privacy policy draft"
Require-File "docs/store-listing-draft-ko.md" "Store listing draft"

Require-Text "pubspec.yaml" "(?m)^version:\s*0\.1\.0\+1\s*$" "pubspec version is 0.1.0+1"
Require-Text "lib/core/constants.dart" "appVersion\s*=\s*'0\.1\.0'" "AppConstants.appVersion matches pubspec build name"
Require-Text "android/app/build.gradle.kts" "applicationId\s*=\s*`"com\.svil\.lovetype_tarot`"" "Android applicationId is com.svil.lovetype_tarot"
Require-Text "android/app/src/main/AndroidManifest.xml" "com\.android\.vending\.BILLING" "Android Billing permission is declared"
Require-Text "android/app/build.gradle.kts" "Missing android/key\.properties" "Release build blocks missing signing config"
Require-Text ".gitignore" "/android/key\.properties" "android/key.properties is ignored"
Require-Text ".gitignore" "/android/\*\.jks" "Android JKS files are ignored"
Require-Text "lib/services/payment_service.dart" "storeAvailable" "Store-unavailable path checks platform store availability"
Require-Text "lib/services/iap_service.dart" "source': 'in_app_purchase'" "IAP receipt payload marks in_app_purchase source"
Require-Text "lib/services/iap_service.dart" "product_type': config\?\.type\.name" "IAP receipt payload includes product_type"

$expectedProducts = @("tarot_1", "tarot_6", "tarot_10p", "tarot_13", "tarot_40", "tarot_sub") | Sort-Object
$iapContent = if (Test-Path -LiteralPath "lib/services/iap_service.dart") {
    Get-Content -LiteralPath "lib/services/iap_service.dart" -Raw -Encoding UTF8
} else {
    ""
}
$actualProducts = [regex]::Matches($iapContent, "'(tarot_(?:1|6|10p|13|40|sub))'\s*:\s*IapProductConfig") |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

$diff = Compare-Object -ReferenceObject $expectedProducts -DifferenceObject $actualProducts
if ($diff) {
    Add-Failure "IAP product catalog differs from store runbook. Expected: $($expectedProducts -join ', '), actual: $($actualProducts -join ', ')"
} else {
    Add-Pass "IAP product catalog matches store runbook"
}

$runtimePngCount = 0
foreach ($assetDir in @("asset/basic_deck", "asset/low_vision_deck", "asset/webtoon_deck", "asset/soul_cards")) {
    if (Test-Path -LiteralPath $assetDir) {
        $runtimePngCount += @(Get-ChildItem -LiteralPath $assetDir -Filter "*.png" -File -Recurse).Count
    }
}
if ($runtimePngCount -eq 0) {
    Add-Pass "Runtime deck and soul-card assets contain no PNG files"
} else {
    Add-Failure "Runtime deck and soul-card assets still contain $runtimePngCount PNG files"
}

if (Test-Path -LiteralPath "android/key.properties") {
    Add-Pass "Local android/key.properties exists for release signing"
} else {
    Add-WarningMessage "Local android/key.properties is missing; release builds require it on the build machine"
}

if (Test-Path -LiteralPath "android/release-lovetype.jks") {
    Add-Pass "Local Android release keystore exists"
} else {
    Add-WarningMessage "Local Android release keystore is missing; release builds require it on the build machine"
}

$ignoredSigning = git status --ignored --short android/key.properties android/release-lovetype.jks 2>$null
if ($ignoredSigning -match "!! android/key\.properties" -and $ignoredSigning -match "!! android/release-lovetype\.jks") {
    Add-Pass "Local signing files are ignored by Git"
} else {
    Add-WarningMessage "Could not confirm both local signing files are ignored by Git"
}

$privacy = if (Test-Path -LiteralPath "docs/privacy-policy-ko.md") {
    Get-Content -LiteralPath "docs/privacy-policy-ko.md" -Raw -Encoding UTF8
} else {
    ""
}
if ($privacy -match "\[.+\]") {
    Add-WarningMessage "Privacy policy still requires operator name, support email, and privacy officer before public submission"
} else {
    Add-Pass "Privacy policy operator fields are filled"
}

if (!$SkipFlutter) {
    Invoke-CheckedCommand "flutter analyze" { flutter analyze }
    Invoke-CheckedCommand "flutter test" { flutter test }
}

if (!$SkipBundleCheck) {
    $bundlePath = "build/app/outputs/bundle/release/app-release.aab"
    if (Test-Path -LiteralPath $bundlePath) {
        $bundle = Get-Item -LiteralPath $bundlePath
        if ($bundle.Length -gt 0) {
            Add-Pass "Release AAB exists: $bundlePath ($([math]::Round($bundle.Length / 1MB, 1)) MB)"
        } else {
            Add-Failure "Release AAB exists but is empty: $bundlePath"
        }
    } else {
        Add-Failure "Release AAB missing. Run: flutter build appbundle --release"
    }
}

Write-Host ""
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "Failures: $($failures.Count)"
Write-Host "Warnings: $($warnings.Count)"

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings requiring external store/operator work:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "- $warning"
    }
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Store readiness verification failed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Local store readiness verification passed." -ForegroundColor Green
exit 0
