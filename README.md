# LoveType Tarot

LoveType Tarot is a Flutter app for AI tarot readings based on a user's soul
card, MBTI, selected keywords, and a three-card spread.

## Current Release State

- App version: `0.1.0+1`
- Android package: `com.svil.lovetype_tarot`
- API base: `https://lovetype-api.railway.app/api/v1`
- Runtime tarot/background assets are optimized as WebP.
- Server cooldown is the source of truth via `GET /api/v1/tarot/cooltime`.
- In-app purchases use the platform store flow and send receipts to
  `POST /api/v1/payment/charge`.
- Android release builds require local signing files and will not fall back to
  the debug key.

## Store Build

Create local signing files from `android/key.properties.example`, then run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
.\tools\verify_store_readiness.ps1
```

The generated Android upload candidate is:

```text
build/app/outputs/bundle/release/app-release.aab
```

Signing files are intentionally ignored by Git:

- `android/key.properties`
- `android/*.jks`
- `android/*.keystore`

## In-App Products

The app and store consoles must use the same product IDs:

| Product ID | Type | Credits |
|---|---|---:|
| `tarot_1` | Consumable | 1 |
| `tarot_6` | Consumable | 6 |
| `tarot_10p` | Consumable | 10 |
| `tarot_13` | Consumable | 13 |
| `tarot_40` | Consumable | 40 |
| `tarot_sub` | Subscription | 0 |

Only `tarot_10p` and `tarot_sub` are exposed in the current purchase dialog.
The other point products are registered in code so the store/server catalog can
be expanded without changing the receipt contract.

## Release Documents

- Store readiness: `docs/store-readiness-2026-06-28.md`
- Store console runbook: `docs/store-console-runbook-2026-06-28.md`
- IAP QA checklist: `docs/qa-iap-store-2026-06-28.md`
- Privacy policy draft: `docs/privacy-policy-ko.md`
- Store listing draft: `docs/store-listing-draft-ko.md`
- Completion audit: `docs/store-registration-completion-audit-2026-06-28.md`

## Local Readiness Gate

Run the store readiness gate before uploading a build:

```powershell
.\tools\verify_store_readiness.ps1
```

The script fails on local release blockers and warns for items that require
store-console or operator information, such as the public privacy policy URL and
store test purchases.
