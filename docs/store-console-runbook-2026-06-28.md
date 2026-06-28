# LoveType Tarot 스토어 콘솔 등록 런북

작성일: 2026-06-28  
목표: Google Play Console / App Store Connect에서 실제 심사 제출 직전까지 필요한 입력값을 한곳에 고정한다.

## 01. 앱 기본 정보

| 항목 | 값 |
|---|---|
| 앱 이름 | LoveType Tarot |
| Android package | `com.svil.lovetype_tarot` |
| 앱 버전 | `0.1.0+1` |
| 카테고리 후보 | 라이프스타일 또는 엔터테인먼트 |
| 기본 언어 | 한국어 |
| 결제 포함 | 예 |
| 로그인 포함 | 예, Google 로그인 및 로컬 사용자 흐름 |
| 푸시 알림 | 예 |

## 02. Google Play 등록 순서

1. Play Console에서 앱을 생성한다.
2. 패키지명이 `com.svil.lovetype_tarot`인지 확인한다.
3. 내부 테스트 트랙을 만든다.
4. `build/app/outputs/bundle/release/app-release.aab`를 업로드한다.
5. 앱 콘텐츠 항목을 작성한다.
6. 개인정보처리방침 URL을 입력한다.
7. 인앱 상품과 구독 상품을 등록한다.
8. 라이선스 테스트 계정을 등록한다.
9. 내부 테스트 배포 후 테스트 결제를 수행한다.

## 03. App Store Connect 등록 순서

1. Bundle ID를 Android package와 동일한 네이밍 정책으로 생성한다.
2. 앱 레코드를 생성하고 이름을 `LoveType Tarot`로 등록한다.
3. 인앱 구입 상품과 구독 상품을 등록한다.
4. Sandbox tester를 등록한다.
5. iOS 빌드를 Xcode 또는 CI에서 아카이브해 업로드한다.
6. 개인정보 라벨과 앱 심사 정보를 작성한다.
7. Sandbox 결제와 복원 테스트를 수행한다.

## 04. 인앱 상품 등록값

| 상품 ID | 타입 | 앱 표시명 | 앱 기준 가격 | 서버 반영 |
|---|---|---|---:|---|
| `tarot_1` | Consumable | 1P 충전 | 100원 | 포인트 1 |
| `tarot_6` | Consumable | 6P 충전 | 600원 | 포인트 6 |
| `tarot_10p` | Consumable | 10P 충전 | 1,000원 | 포인트 10 |
| `tarot_13` | Consumable | 13P 충전 | 1,300원 | 포인트 13 |
| `tarot_40` | Consumable | 40P 충전 | 4,000원 | 포인트 40 |
| `tarot_sub` | Subscription | 월 구독 | 4,900원 | 구독 활성화 |

현재 앱 UI에서 직접 노출되는 상품은 `tarot_10p`, `tarot_sub`다. 나머지 상품은 콘솔/서버 카탈로그 확장용으로 먼저 맞춰 둔다.

## 05. 서버 검증 체크

`POST /api/v1/payment/charge`는 아래 조건을 만족해야 한다.

- 스토어 영수증 검증 성공 전에는 포인트나 구독을 지급하지 않는다.
- `transaction_id` 또는 스토어 주문 ID 기준으로 중복 지급을 차단한다.
- 클라이언트의 `amount`는 참고값으로만 쓰고, 서버 상품 테이블의 포인트/구독 값을 최종 기준으로 삼는다.
- `tarot_sub`는 포인트 지급이 아니라 구독 상태와 만료일을 갱신한다.
- 검증 실패 시 앱에는 실패 메시지가 표시되고 서버 직접충전은 발생하지 않는다.

## 06. 심사 자료 입력값

짧은 설명:

```text
소울카드와 MBTI로 읽는 AI 타로 이야기
```

긴 설명은 `docs/store-listing-draft-ko.md`를 사용한다.

개인정보처리방침은 `docs/privacy-policy-ko.md`의 운영자 정보 항목을 채운 뒤 공개 URL로 게시한다.

## 07. 실제 제출 전 차단 항목

- 운영자명, 고객지원 이메일, 개인정보 보호 책임자 미확정
- 개인정보처리방침 공개 URL 미확정
- Play/App Store 상품 ID 미등록
- 서버 영수증 검증 credential 미연결
- 내부 테스트 트랙 또는 Sandbox 결제 미검증

위 항목은 로컬 코드만으로 완료할 수 없으며 스토어 계정과 운영자 정보가 필요하다.
