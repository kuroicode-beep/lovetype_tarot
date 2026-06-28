# LoveType Tarot 스토어 등록 직전 완료 감사

작성일: 2026-06-28  
검증 기준: 로컬 앱/문서/빌드 산출물이 실제 스토어 등록 직전 상태를 뒷받침하는지 확인한다.

## 01. 완료로 확인된 항목

| 항목 | 증거 |
|---|---|
| Android release AAB 생성 | `build/app/outputs/bundle/release/app-release.aab` |
| Release signing debug key fallback 차단 | `android/app/build.gradle.kts` |
| Signing secret Git 제외 | `.gitignore`, `android/key.properties.example` |
| 런타임 카드/배경 asset WebP 최적화 | `asset/**/*.webp`, `pubspec.yaml` |
| 서버 쿨타임 SSOT | `lib/screens/main_screen.dart`, `lib/screens/result_screen.dart`, `lib/services/api_service.dart` |
| 결제 직접충전 fallback 제거 | `lib/services/payment_service.dart` |
| IAP 상품 ID 중앙화 | `lib/services/iap_service.dart` |
| IAP 상품 ID 회귀 테스트 | `test/widget_test.dart` |
| 스토어 등록 문안 | `docs/store-listing-draft-ko.md` |
| 개인정보처리방침 초안 | `docs/privacy-policy-ko.md` |
| 스토어 콘솔 런북 | `docs/store-console-runbook-2026-06-28.md` |
| IAP QA 체크리스트 | `docs/qa-iap-store-2026-06-28.md` |

## 02. 마지막으로 수행한 검증 명령

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
.\tools\verify_store_readiness.ps1
```

이 감사 문서를 갱신할 때는 위 명령을 다시 실행하고 결과를 아래 기록에 추가한다.

## 03. 현재 산출물

| 산출물 | 위치 |
|---|---|
| Android AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Store readiness | `docs/store-readiness-2026-06-28.md` |
| Store runbook | `docs/store-console-runbook-2026-06-28.md` |
| IAP QA | `docs/qa-iap-store-2026-06-28.md` |
| Privacy draft | `docs/privacy-policy-ko.md` |
| Store listing draft | `docs/store-listing-draft-ko.md` |
| Readiness verifier | `tools/verify_store_readiness.ps1` |
| CI readiness workflow | `.github/workflows/store-readiness.yml` |

## 04. 외부 상태가 필요한 미완료 항목

다음 항목은 로컬 저장소에서 임의로 완료 처리할 수 없다.

- Google Play Console 또는 App Store Connect 앱 생성
- 공개 개인정보처리방침 URL 게시
- 운영자명, 고객지원 이메일, 개인정보 보호 책임자 확정
- 인앱 상품 및 구독 상품 등록
- 라이선스 테스트 계정 또는 Sandbox tester 등록
- 서버 스토어 영수증 검증 credential 연결
- 실제 테스트 결제와 구독 복원 검증

## 05. 완료 판정

로컬 코드, 문서, Android 빌드 산출물은 스토어 등록 직전 준비 상태다.

실제 결제 가능 상태와 심사 제출 가능 상태는 스토어 콘솔 및 서버 credential 연결 이후에만 확정할 수 있다. 따라서 현재 저장소 기준 완료 범위는 "로컬 앱과 등록 준비 산출물 완료"이며, "상점 계정에 실제 등록 완료"는 외부 작업으로 남아 있다.
