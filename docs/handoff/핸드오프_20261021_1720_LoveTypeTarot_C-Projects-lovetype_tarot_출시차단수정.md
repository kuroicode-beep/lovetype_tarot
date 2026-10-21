## 대상
- 프로젝트: LoveType Tarot / lovetype-api
- 작업 폴더: C:\Projects\lovetype_tarot (서버 C:\Projects\lovetype-api)
- 세션 시각: 2026-10-21 17:20 KST

## 세션 요약
- 사용자 지시 “남은작업 추가작업 진행”에 따라 문서 통합, 테스트 환경 복구, 인증·결제·쿨타임·구매 복구·히스토리 큐·접근성을 수정했다.
- 앱 0.2.0+2는 로컬 검증 후보이며 실서비스 출시가 아니다. 의도적으로 중지된 운영 API는 재기동하지 않았다.

## 완료된 작업
- 스토어 문서 6개를 기존 c0a48a1 이력 그대로 master에 통합했다.
- 앱 커밋 9e3e172c9b56216d00c5d49d9c40ac7c2e6e9421, origin/master 일치·작업 트리 clean을 확인했다.
- Google ID 토큰 검증·사용자 귀속, Play 상품/구독 검증·거래별 중복 지급 차단, 영수증 암호화 대기 큐·서버 승인 후 소비/승인, 서버 리딩 생성·차감·저장·쿨타임 트랜잭션, 히스토리 큐 직렬화를 구현했다.
- 앱 정적 분석 문제0, 테스트21개 통과. 서버 테스트12개 통과, 서버 원격 보안 CI 성공.
- 최종 AAB 76,794,534바이트, ZIP745항목 CRC 정상, jarsigner 검증0. SHA256 B1C95F1DE4482083375CBB104651FAE66843CACB2F35F55DBC2DFB4ACB381C54.
- dist/android/앱_20261021_LoveTypeTarot_v0.2.0_검증용.aab 사본 해시 및 바탕화면 배포폴더 바로가기를 재조회했다. 시작프로그램은 모바일 앱이므로 등록하지 않았다.
- 스토어 정적검사 실패0/경고0. LINESeedKR 정본2개 해시 일치, 12미만 글자0, 라이선스 번들 포함.
- 서버 코드20cbee2·CI1cf9bfe를 codex/tarot-release-security로 푸시하고 초안 PR #1을 연결했다. main 병합과 운영 재기동은 보류했다.

## 진행 중 / 미완료 작업
- 앱 원격 Store Readiness CI run39568428114가 분석·테스트·스토어 정적검사·Android debug APK 빌드까지 모두 성공했다. 소스 커밋9e3e172의 결과이며 이후 변경은 기록 문서뿐이다.
- Google OAuth 웹 클라이언트 ID, Play 계정·상품·테스터·Publisher 권한, 실제 PostgreSQL 동시성 및 기기 결제·복원·알림은 미검증이다. 검증용 AAB는 OAuth 빌드 값이 없는 상태이므로 실제 로그인 준비 완료로 볼 수 없다.
- iOS 영수증 검증은 fail-closed, 구독 RTDN·환불 처리와 Firebase 실설정이 남아 있다. npm moderate8건 및 Android 빌드 도구 지원 경고도 남긴다.
- 통합된 예전 워크트리의 git worktree remove가 권한 오류로 일부 정리됐고, 잔여 폴더 강제 삭제는 자동 승인 정책에 거절됐다. 현재 git worktree list에는 master만 있으나 .claude/worktrees/store-registration-b9ddca와 .git/worktrees/store-registration-b9ddca 잔여 폴더 및 복구용 기존 브랜치는 보존했다. 원본 c0a48a1은 master와 원격에 포함돼 있다. 삭제 우회·추가 재시도는 하지 않는다.
- 공개 랜딩페이지 신설은 사용자 결정 대기다.

## 주요 결정사항 / 규칙
- 서비스 중지 기록: Outline svil-infra 문서 c1aa9c7b-7903-449e-8b71-e3d736e5093c 및 현재 Railway stopped/FAILED 상태 대조. /health의 단순200을 실제 타로 API 정상으로 간주하지 않았다.
- 설정이 없는 영수증·로그인은 성공으로 우회하지 않는다. 기존 닉네임 지갑과 과거 대기 기록을 임의로 Google 계정에 합치지 않는다.
- 실제 배포 전 백업·추가 마이그레이션·새 앱/서버 동시 적용·인증/실결제 검증이 필요하다.

## 참고 정보
- 서버 PR: https://github.com/kuroicode-beep/lovetype-api/pull/1
- 보고서: docs/reports/완료보고_20261021_출시차단수정_코덱스.md
- 요약 근거: docs/reports/근거_20261021_출시차단수정_코덱스.json
- 설정 빌드: tools/build_store_candidate.ps1 (GOOGLE_WEB_CLIENT_ID, API_BASE_URL)
- 서버 설정: docs/운영설정_20261021_타로결제보안_코덱스.md
- 프로젝트 위키: https://outline.svil.dev/doc/lovetype-tarot-AE5jC4JOxj

## 다음 세션 시작 시 할 일
1. 원격 CI와 최신 계정·서비스 중지 상태를 재조회하고 이미 통과한 단계는 반복하지 않는다.
2. 실제 Google/Play 설정 후 PostgreSQL 동시성·기기 결제·복원 검증, 승인된 서비스 재개를 진행한다.
3. 잔여 워크트리 폴더는 정책·권한 문제가 해소된 뒤 검증된 정확한 경로만 정리한다.
