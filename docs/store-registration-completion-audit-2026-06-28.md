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
- 인앱 상품 및 구독 상품 등록
- 라이선스 테스트 계정 또는 Sandbox tester 등록
- 서버 스토어 영수증 검증 credential 연결
- 실제 테스트 결제와 구독 복원 검증

### 2026-07-08 진행분

- 운영자명, 고객지원 이메일, 개인정보 보호 책임자 확정: `docs/privacy-policy-ko.md` 09 문의 항목 기입 완료
- 개인정보처리방침 Ghost 블로그 draft 등록 완료 (post id `6a4df4a528e44400013826a1`)
  - 발행 후 URL: `https://ghost-production-0ec2.up.railway.app/lovetype-tarot-gaeinjeongboceoribangcim/`
  - Ghost 관리자에서 publish 승인만 남음 (운영자 이메일 공개 게시 최종 확인 포함)
- 개인정보처리방침 발행 완료 (2026-07-08 16:07 KST): 공개 URL `https://ghost-production-0ec2.up.railway.app/lovetype-tarot-gaeinjeongboceoribangcim/`

### 2026-07-08 차단 발견: Google Play 개발자 계정 상태

Play Console 접속 결과 개발자 계정 `Lee Du Yeon`(ID 7770188165020085052)이 다음 상태다.

- 2024-12-17 계정 확인(본인 인증) 기한 초과로 개발자 프로필과 모든 앱이 Google Play에서 삭제됨
- 계정 상태: 제한된 개발자 계정 — 새 앱 게시 불가
- 해결 경로: Play Console의 "개발자 계정 인증" 절차 완료 (계정 유형 확인 → 결제 프로필 연결 → 계정 정보 제공 → 공개/비공개 세부정보 제공)
- 본인 인증(신분증, 결제 프로필)은 계정 소유자가 직접 수행해야 함
- 인증 완료 전에는 앱 생성/AAB 업로드/인앱 상품 등록이 모두 무의미하므로 스토어 등록 작업은 계정 인증 완료가 선행 조건

### 2026-07-08 오후 재확인: 계정 인증 진행 상태

계정 소유자가 개발자 계정 인증 절차를 진행한 뒤의 콘솔 상태.

- 계정 유형 확정: 개인 계정
- 법적 이름/주소, 연락처 이메일(인증됨), 개발자 이메일(svil.admin@gmail.com, 인증됨), 웹사이트(Ghost 블로그) 입력 완료
- 남은 이슈 1 — "Google에서 신원을 확인할 수 없습니다": 제출 정보 Google 검토 중, 최대 7일 소요 (이슈 4988607639423817101)
- 남은 이슈 2 — "연락처 전화번호를 인증하지 않았습니다": 신원 인증(신분증 승인) 완료가 선행 조건이라 현재 잠김. 신원 승인 후 계정 세부정보에서 SMS 인증 코드로 진행 (이슈 4986491442003379490)
- 홈의 "앱 만들기" 버튼은 잠금 상태 — 두 이슈 해결 전 앱 생성 불가

결론: 콘솔에서 즉시 수행 가능한 작업은 없음. Google 신원 검토 완료(최대 7일) → 전화번호 SMS 인증 → 계정 복구 → 앱 생성/AAB 업로드/IAP 등록 순서로 재개한다.

이번 진행분은 문서 변경만 포함하므로 코드 검증 명령 재실행 대상이 아니다.

## 05. 완료 판정

로컬 코드, 문서, Android 빌드 산출물은 스토어 등록 직전 준비 상태다.

실제 결제 가능 상태와 심사 제출 가능 상태는 스토어 콘솔 및 서버 credential 연결 이후에만 확정할 수 있다. 따라서 현재 저장소 기준 완료 범위는 "로컬 앱과 등록 준비 산출물 완료"이며, "상점 계정에 실제 등록 완료"는 외부 작업으로 남아 있다.
