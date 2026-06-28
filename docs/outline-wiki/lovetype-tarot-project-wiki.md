# LoveType Tarot 프로젝트 위키

LoveType Tarot은 소울카드, MBTI, 3장 타로 스프레드, AI 스토리 생성, 포인트/구독, 푸시 알림을 연결한 Flutter 기반 연애/일상 타로 앱이다.

## 01. 빠른 링크

- [LoveType Tarot PRD](https://outline-production-20a7.up.railway.app/doc/lovetype-tarot-prd-svikV4U9Bd)
- [LoveType Tarot 구현 스펙](https://outline-production-20a7.up.railway.app/doc/lovetype-tarot-wnWOsbAyiJ)
- [LoveType Tarot 아키텍처](https://outline-production-20a7.up.railway.app/doc/lovetype-tarot-JkVWS4xSUt)
- [LoveType Tarot 개발진행 히스토리](https://outline-production-20a7.up.railway.app/doc/lovetype-tarot-gEOugCby9f)
- [LoveType Tarot 완료보고서 인덱스](https://outline-production-20a7.up.railway.app/doc/lovetype-tarot-MmxMzcSuSW)

## 02. 현재 기준

- 현재 앱 버전: `0.1.0+1`
- 앱 식별자: `lovetype-tarot`
- 클라이언트: Flutter 3.38.5 / Dart 3.10.4
- 백엔드: Railway `lovetype-api`
- API Base: `https://lovetype-api.railway.app`
- 쿨타임 기준: 서버 `GET /api/v1/tarot/cooltime` 단일 진실 원천
- 스토어 준비 상태: 로컬 앱/문서/Android AAB/CI 검증 완료, 실제 스토어 콘솔 등록과 결제 검증은 외부 운영 정보 필요
- 최신 검증 게이트: `tools/verify_store_readiness.ps1`
- GitHub Actions: `.github/workflows/store-readiness.yml`
- 저장소 문서 위치: `C:\Projects\lovetype_tarot\docs`
- Outline 원본 위치: `C:\Projects\lovetype_tarot\docs\outline-wiki`

## 03. 문서 구조

### PRD

제품 목표, 사용자, MVP 범위, 성공 기준, 주요 리스크를 정리한다.

### 구현 스펙

앱 버전, 라우팅, 서비스, 데이터 모델, 화면 흐름, 서버 쿨타임 정책, 테스트 기준을 정리한다.

### 아키텍처

Flutter 앱, 로컬 저장소, Railway API, Firebase/FCM, IAP, Outline 문서 체계의 연결을 정리한다.

### 개발진행 히스토리

초기 MVP 문서, 코드 검수, 서버 쿨타임 전환, 검증 결과를 시간순으로 정리한다.

### 완료보고서 인덱스

검수 보고서, 기능 정의, 개선 의견, Outline 위키 구축 보고서, 스토어 등록 직전 완료 감사, 남은 외부 작업의 위치와 검색 키워드를 정리한다.

## 04. 스토어 등록 직전 상태

로컬 기준 완료:

- Android release AAB 생성 완료: `build/app/outputs/bundle/release/app-release.aab`
- Android release signing 설정 및 debug key fallback 차단
- 런타임 카드/배경 asset WebP 최적화
- 서버 쿨타임 SSOT 전환
- 인앱결제 store flow 정리 및 서버 직접충전 fallback 제거
- IAP 상품 ID 중앙화 및 회귀 테스트 추가
- 스토어 등록 문안, 개인정보처리방침 초안, 콘솔 런북, QA 문서 작성
- 로컬 readiness verifier 추가
- GitHub Actions readiness workflow 통과

남은 외부 작업:

- Google Play Console 또는 App Store Connect 앱 생성
- 공개 개인정보처리방침 URL 게시
- 운영자명, 고객지원 이메일, 개인정보 보호 책임자 확정
- 인앱 상품 및 구독 상품 등록
- 라이선스 테스트 계정 또는 Sandbox tester 등록
- 서버 스토어 영수증 검증 credential 연결
- 실제 테스트 결제와 구독 복원 검증

## 05. 기준 원본 문서

- `docs/01_전체코드검수.md`
- `docs/02_상세기능정의.md`
- `docs/03_개선의견.md`
- `docs/lovetype_mvp_api_spec_v1.txt`
- `docs/lovetype_mvp_db_spec_v1.txt`
- `docs/lovetype_mbti_test_master_doc_v1.txt`
- `docs/Resource_20260312_LoveType_MVP_JSON_통합초안_v1.txt.txt`
- `docs/store-registration-completion-audit-2026-06-28.md`
- `docs/store-console-runbook-2026-06-28.md`
- `docs/qa-iap-store-2026-06-28.md`
