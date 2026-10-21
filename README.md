# LoveType Tarot

LoveType Tarot is a Flutter app for AI tarot readings based on a user's soul
card, MBTI, selected keywords, and a three-card spread.

## Current Release State

- App version: `0.2.0+2` (2026-10-21 local verification candidate)
- Android package: `com.svil.lovetype_tarot`
- API base: `https://lovetype-api.railway.app/api/v1` (production service is intentionally stopped pending release)
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

## 2026-10-21 검증 후보

기존 스토어 문서 진행분을 통합하고 Google 인증, 서버 영수증 검증·중복 지급 차단, 구매 실패 복구, 쿨타임 계약, 히스토리 큐 및 접근성을 보완했다. 서버 변경은 [배포 보류 초안 PR](https://github.com/kuroicode-beep/lovetype-api/pull/1)에 있으며 아직 운영 서버에 적용하지 않았다.

로컬 기본 빌드는 컴파일·서명 검증용이다. 실제 로그인에는 `GOOGLE_WEB_CLIENT_ID` 빌드 값과 같은 서버 `GOOGLE_CLIENT_ID`가 필요하다. 실제 배포 후보는 설정 파일에 `GOOGLE_WEB_CLIENT_ID`, `API_BASE_URL`을 넣고 `tools/build_store_candidate.ps1`로 만든다. 서버는 Play 계정·검증 권한을 구성하고 기존 의도적 중지 상태의 재개를 확인한 뒤 새 앱과 함께 배포한다. iOS 결제·구독 RTDN·스토어 실결제 검증은 남아 있다.

현재 SDK·패키지 설정은 Flutter 3.47.2 / Dart 3.13.2로 검증했다. 기존 SDK를 업데이트하거나 다른 세션의 캐시를 초기화하지 않았다.

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

## CI

GitHub Actions runs `.github/workflows/store-readiness.yml` on `master`, pull
requests, and manual dispatch. CI verifies dependencies, analysis, tests, the
store readiness static gate, and a debug APK smoke build. Release AAB signing
stays local because the upload keystore is intentionally not committed.
