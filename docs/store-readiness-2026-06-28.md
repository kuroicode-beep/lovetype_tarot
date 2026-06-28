# LoveType Tarot 스토어 등록 직전 체크리스트

작성일: 2026-06-28  
범위: Google Play / App Store 상품 등록과 심사 제출 직전까지의 앱 준비 상태

## 01. 현재 완료

- 인앱결제 플러그인 연결: `in_app_purchase`
- 결제 시작 플로우: `IapService.buy`
- 구매 스트림 처리: pending, error, canceled, restored, purchased
- 구매 영수증 서버 전달: `POST /api/v1/payment/charge`
- 포인트 차감: `POST /api/v1/payment/use`
- 잔액/구독 조회: `GET /api/v1/payment/balance`
- 스토어 미사용 환경에서 서버 직접충전 fallback 제거
- Android release signing이 debug key를 쓰지 않도록 차단
- Android Billing permission 명시
- 카드/배경 런타임 이미지를 WebP로 최적화
- 로컬 release keystore 생성 완료: `android/release-lovetype.jks`
- release AAB 생성 완료: `build/app/outputs/bundle/release/app-release.aab`

## 02. 스토어 상품 ID

앱 코드 기준 상품 ID는 다음과 같다. 스토어 콘솔과 서버 상품 테이블은 이 ID와 정확히 일치해야 한다.

| 상품 ID | 타입 | 앱 표시 | 크레딧 |
|---|---|---|---:|
| `tarot_10p` | consumable | 10P 충전 | 10 |
| `tarot_1` | consumable | 1P 충전 | 1 |
| `tarot_6` | consumable | 6P 충전 | 6 |
| `tarot_13` | consumable | 13P 충전 | 13 |
| `tarot_40` | consumable | 40P 충전 | 40 |
| `tarot_sub` | subscription | 월 구독 | 0 |

현재 결제 다이얼로그는 `tarot_10p`, `tarot_sub`만 노출한다. 나머지 포인트 상품은 스토어 등록/서버 검증 준비용으로 코드에 정의되어 있다.

## 03. 서버 계약

`POST /api/v1/payment/charge` 요청 필드:

```json
{
  "app_id": "lovetype-tarot",
  "user_id": "local_<nickname> or google uid",
  "product_id": "tarot_10p",
  "receipt": "<store verification data>",
  "amount": 10,
  "product_type": "consumable",
  "platform": "android",
  "transaction_id": "<purchase id>",
  "source": "in_app_purchase"
}
```

서버 필수 검증:

- `product_id`가 허용 목록에 있는지 확인
- `transaction_id` 중복 지급 방지
- 스토어 영수증 검증 성공 후에만 포인트/구독 반영
- `tarot_sub`는 포인트 지급이 아니라 구독 상태/만료일 갱신
- 클라이언트가 보낸 `amount`는 참고값으로만 사용하고 서버 상품 테이블 기준으로 최종 반영

## 04. Android release signing

`android/key.properties`를 로컬에 만들고 Git에는 커밋하지 않는다.

예시는 `android/key.properties.example`에 있다. 실제 파일은 아래 형식으로 만든다.

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=lovetype
storeFile=../release-lovetype.jks
```

키 파일 예시 위치:

```text
C:\Projects\lovetype_tarot\android\release-lovetype.jks
```

`android/key.properties`, `*.jks`, `*.keystore`는 `.gitignore`에 추가되어 있다.

주의:

- `android/key.properties`와 `android/release-lovetype.jks`는 로컬에 생성되어 있으며 Git에 커밋되지 않는다.
- 이 키를 잃으면 동일 패키지의 업데이트 배포가 어려워질 수 있으므로 안전한 비밀 저장소에 백업한다.

## 05. 빌드 명령

debug QA:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

스토어 업로드 후보:

```powershell
flutter build appbundle --release
```

현재 생성 결과:

- `app-release.aab`: 약 60.5MB
- debug APK: 약 165.7MB

`android/key.properties`가 없으면 release 빌드는 실패해야 정상이다. debug key로 release가 만들어지면 안 된다.

## 06. 스토어 콘솔 등록 직전 남은 일

- Google Play Console 앱 생성
- `com.svil.lovetype_tarot` 패키지명 확인
- 인앱 상품과 구독 상품 ID 등록
- 라이선스 테스트 계정 등록
- 내부 테스트 트랙 업로드
- 서버 영수증 검증 연동 확인
- 개인정보처리방침 URL 준비: 초안은 `docs/privacy-policy-ko.md`
- 앱 아이콘/스크린샷/설명/카테고리/콘텐츠 등급 준비

## 07. QA 합격 기준

- 스토어 상품 조회 성공
- `tarot_10p` 테스트 구매 성공
- 구매 후 서버 잔액 증가
- 동일 `transaction_id` 재전송 시 중복 충전 없음
- `tarot_sub` 테스트 구매 후 `is_subscribed=true`
- 구매 취소 시 잔액/구독 상태 변화 없음
- 스토어 사용 불가 환경에서 서버 직접충전이 발생하지 않음
