import '../core/soul_card.dart';

/// 사용자 프로필 모델
class UserModel {
  final String nickname;
  final String gender; // 'male' | 'female' | 'other'
  final String mbti; // 예: 'INFP'
  final String birthdate; // 'YYYYMMDD'
  final int soulCardNumber; // 1~9 (calcSoulCard 결과)

  const UserModel({
    required this.nickname,
    required this.gender,
    required this.mbti,
    required this.birthdate,
    required this.soulCardNumber,
  });

  factory UserModel.fromBirthdate({
    required String nickname,
    required String gender,
    required String mbti,
    required String birthdate,
  }) {
    return UserModel(
      nickname: nickname,
      gender: gender,
      mbti: mbti,
      birthdate: birthdate,
      soulCardNumber: calcSoulCard(birthdate),
    );
  }

  String get soulCardName => soulCardNames[soulCardNumber] ?? '알 수 없음';

  UserModel copyWith({
    String? nickname,
    String? gender,
    String? mbti,
    String? birthdate,
    int? soulCardNumber,
  }) {
    return UserModel(
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      mbti: mbti ?? this.mbti,
      birthdate: birthdate ?? this.birthdate,
      soulCardNumber: soulCardNumber ?? this.soulCardNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'gender': gender,
        'mbti': mbti,
        'birthdate': birthdate,
        'soul_card_number': soulCardNumber,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        nickname: json['nickname'] as String,
        gender: json['gender'] as String,
        mbti: json['mbti'] as String,
        birthdate: json['birthdate'] as String,
        soulCardNumber: json['soul_card_number'] as int,
      );
}
