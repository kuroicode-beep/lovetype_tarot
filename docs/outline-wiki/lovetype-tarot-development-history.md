# LoveType Tarot 개발진행 히스토리

## 01. 요약

LoveType Tarot은 2026년 3월 MVP 기획/스펙 문서에서 시작해 Flutter 앱, API 연동, 카드 에셋, 결제/푸시/히스토리 서비스를 갖춘 상태다. 2026년 6월 28일 기준으로 서버 쿨타임을 단일 기준으로 사용하도록 앱 구조를 정리했다.

## 02. 주요 마일스톤

### 2026-03-12 MVP 문서화

- API 명세서 작성
- DB 명세서 작성
- MBTI 테스트 마스터 문서 작성
- LoveType MVP JSON 통합 초안 작성
- 카드덱 생성/프롬프트 문서 작성

관련 문서:
- `docs/lovetype_mvp_api_spec_v1.txt`
- `docs/lovetype_mvp_db_spec_v1.txt`
- `docs/lovetype_mbti_test_master_doc_v1.txt`
- `docs/Resource_20260312_LoveType_MVP_JSON_통합초안_v1.txt.txt`

### 2026-03-27 코드 검수와 기능 정의

- Flutter 앱 전체 구조 검수
- 화면/서비스/데이터 흐름 정리
- 개선 의견 도출

관련 문서:
- `docs/01_전체코드검수.md`
- `docs/02_상세기능정의.md`
- `docs/03_개선의견.md`

### 2026-06-28 서버 쿨타임 전환

- `MainScreen`의 로컬 쿨타임 저장/계산 제거
- `ApiService.getReadingCooltime` 추가
- `TarotCooltimeStatus` 파서 추가
- 버튼 탭 시 서버 쿨타임 재확인
- 결과 생성 후 서버 기준 쿨타임 알림 예약
- 로컬 쿨타임 상수와 StorageService 메서드 제거
- 관련 테스트 추가

검증:
- `flutter analyze` 통과
- `flutter test` 통과
- `flutter build apk --debug` 통과

### 2026-06-28 Outline 프로젝트 위키 구축

- `docs/outline-wiki/` 원본 생성
- 허브, PRD, 구현 스펙, 아키텍처, 개발진행 히스토리, 완료보고서 인덱스 구성
- Outline 게시 및 readback 검증

## 03. 현재 운영 상태

- 앱 버전: `0.1.0+1`
- 코드 분석: 통과
- 단위 테스트: 통과
- Android debug APK: 빌드 성공
- 서버 쿨타임: 앱 기준으로 통합 완료, 실제 운영 응답 QA 필요

## 04. 남은 확인 포인트

- Railway `tarot/cooltime` 실응답과 앱 파서 필드 정합성
- 포인트 차감 실패/재시도 UX
- 릴리즈 signing config
- APK/AAB 용량 최적화
- API Base 환경 분리
- 주요 화면 widget/golden 테스트 보강

