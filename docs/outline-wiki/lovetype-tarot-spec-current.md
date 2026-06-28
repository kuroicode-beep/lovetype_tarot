# LoveType Tarot 구현 스펙

작성일: 2026-06-28  
기준 버전: `0.1.0+1`

## 01. 버전 관리

- `pubspec.yaml`: `0.1.0+1`
- `AppConstants.appVersion`: `0.1.0`
- 초기 빌드 정책: `0.1.0` 기준, 스토어 빌드는 `+` 뒤 build number 증가

## 02. 라우팅 / 진입점

- 진입점: `lib/main.dart`
- 앱 루트: `LoveTypeTarotApp`
- named routes: `/`, `/signup`, `/info-input`, `/main`, `/keyword`
- `/soul-card`는 `onGenerateRoute`로 사용자 인자 전달
- 카드 뽑기, 카드 확인, 결과 화면은 생성자 인자가 있어 `MaterialPageRoute` 직접 이동

## 03. 세션과 인증

- 로컬 프로필은 `StorageService`가 `SharedPreferences`에 저장
- Google 로그인은 `AuthService`와 `ApiService.authGoogle` 경로 사용
- 서버 access token은 `ApiService.setBearerToken`으로 설정 가능
- OAuth 미연동 시 히스토리/결제용 사용자 식별자는 `local_<nickname>`

## 04. 데이터 모델

- `UserModel`: 닉네임, 성별, MBTI, 생년월일, 소울카드 번호
- `TarotCard`: 카드 이름, 슈트, 정역 방향
- `ReadingArgs`: 주제, 라벨, 태그, 선택 카드
- `ReadingResult`: 리딩 결과 데이터 구조

## 05. 주요 서비스

- `ApiService`: REST GET/POST, 인증, 결제, 푸시, 타로 리딩, 히스토리, 서버 쿨타임
- `StorageService`: 프로필, 테마, 포인트/구독 캐시, 푸시 설정, 히스토리 대기 큐
- `PaymentService`: 잔액 조회, 포인트 사용, 충전, 구독 상태 반영
- `IapService`: 스토어 상품 조회/구매/검증
- `NotificationService`: 로컬 알림, FCM 초기화, 쿨타임 해제 알림
- `HistorySyncService`: 리딩 히스토리 서버 저장, 실패 시 로컬 큐
- `TtsService`: 결과 읽기

## 06. 서버 쿨타임 정책

- 서버 `GET /api/v1/tarot/cooltime`이 단일 진실 원천이다.
- 앱은 `topic=daily|romance`, `category_key=today|love`, `app_id`, `user_id`를 쿼리로 보낸다.
- 응답 파서는 다음 필드를 수용한다.
  - `is_available` / `isAvailable` / `available` / `can_read`
  - `next_available_at` / `nextAvailableAt` / `available_at` / `unlock_at`
  - `remaining_seconds` / `cooldown_seconds` / `remaining`
- 메인 화면은 진입 시 두 주제를 조회하고, 버튼 탭 시 해당 주제를 재확인한다.
- 로컬 마지막 리딩 시각 저장은 사용하지 않는다.

## 07. 주요 화면 스펙

- `IntroScreen`: 시작/로그인 진입
- `SignupScreen`: Google 계정 연결
- `InfoInputScreen`: 프로필 입력 및 소울카드 계산
- `SoulCardScreen`: 소울카드 결과 표시
- `MainScreen`: 쿨타임/포인트 상태 기반 리딩 진입
- `KeywordScreen`: 주제별 키워드 선택
- `CardDrawScreen`: 7장 중 3장 선택
- `CardConfirmScreen`: 선택 카드 확인
- `ResultScreen`: AI 결과, 저장, 공유, TTS, 알림 예약

## 08. 접근성 / 테마

- `AppTheme.darkTheme`
- `AppTheme.highContrastTheme`
- `AppState.highContrast`로 테마 전환
- 고대비 모드에서는 `low_vision_deck` 경로 사용
- 구독 상태에서는 웹툰 덱 사용 가능

## 09. 검증

- `flutter analyze`: 통과
- `flutter test`: 통과
- `flutter build apk --debug`: 통과
- 추가된 테스트: `TarotCooltimeStatus` 서버 응답 파서

