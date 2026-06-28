# LoveType Tarot 완료보고서 인덱스

## 01. 문서 위치

- 로컬 문서 루트: `C:\Projects\lovetype_tarot\docs`
- Outline 원본 루트: `C:\Projects\lovetype_tarot\docs\outline-wiki`
- 검증/작업 보고서 위치: `docs/codex-verification-YYYY-MM-DD-*.md`

## 02. 핵심 규칙

- Outline에는 탐색 가능한 위키 구조로 게시한다.
- 로컬 원본 Markdown을 저장소에 남겨 재게시 가능하게 유지한다.
- 서버 쿨타임은 앱의 단일 기준으로 기록한다.
- 문서 수정 후 `flutter analyze`, `flutter test`, 필요 시 `flutter build apk --debug` 결과를 함께 남긴다.
- 스토어 등록 직전 상태는 `tools/verify_store_readiness.ps1`와 GitHub Actions `Store Readiness` 결과를 함께 확인한다.

## 03. 주요 완료보고서 / 기준 문서

| 문서 | 역할 |
|---|---|
| `docs/01_전체코드검수.md` | 앱 구조, 모듈, 외부 연동, 테스트/품질 검수 |
| `docs/02_상세기능정의.md` | 화면별 기능과 데이터 전달, 서버 쿨타임 정책 |
| `docs/03_개선의견.md` | 운영 QA, 릴리즈, 테스트, 용량, 환경 분리 개선 과제 |
| `docs/lovetype_mvp_api_spec_v1.txt` | MVP API 계약 원본 |
| `docs/lovetype_mvp_db_spec_v1.txt` | MVP DB 구조 원본 |
| `docs/outline-wiki/*.md` | Outline 게시 원본 |
| `docs/store-readiness-2026-06-28.md` | 스토어 등록 직전 체크리스트 |
| `docs/store-console-runbook-2026-06-28.md` | Play Console / App Store Connect 등록 런북 |
| `docs/qa-iap-store-2026-06-28.md` | 인앱결제 QA 체크리스트 |
| `docs/store-registration-completion-audit-2026-06-28.md` | 스토어 등록 직전 완료 감사와 남은 외부 작업 |
| `tools/verify_store_readiness.ps1` | 로컬 스토어 readiness 자동 검증 |
| `.github/workflows/store-readiness.yml` | 원격 CI readiness 검증 |

## 04. 스토어 등록 직전 남은 작업

아래 항목은 로컬 저장소에서 임의로 완료 처리할 수 없고, 스토어 계정 또는 운영자 정보가 필요하다.

- Google Play Console 또는 App Store Connect 앱 생성
- 공개 개인정보처리방침 URL 게시
- 운영자명, 고객지원 이메일, 개인정보 보호 책임자 확정
- 인앱 상품 및 구독 상품 등록
- 라이선스 테스트 계정 또는 Sandbox tester 등록
- 서버 스토어 영수증 검증 credential 연결
- 실제 테스트 결제와 구독 복원 검증

## 05. 검색 키워드

- LoveType Tarot
- lovetype-tarot
- Flutter
- 서버 쿨타임
- tarot/cooltime
- 소울카드
- MBTI
- 3카드 스프레드
- Railway lovetype-api
- 고대비
- low_vision_deck
- webtoon_deck
- 포인트
- 구독
- FCM
- Outline 프로젝트 위키
- Store Readiness
- IAP QA
- app-release.aab
- Play Console
- App Store Connect
