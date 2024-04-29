class UserInfo {
  final String snsUserName;
  final int indexId;

  UserInfo({required this.snsUserName, required this.indexId});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(snsUserName: json['snsUsrName'], indexId: json['indexId']);
  }
}

// 사용자 개인정보, 랭킹전 참여여부등
class UserPrivacyInfo {
  final String snsQuestInfoId;
  final bool isEventAgree;
  final bool isPrivacyAgree;
  final String? name;
  final String? phoneNumber;
  final bool isExposeRank;
  final bool isBadgeTesterMode;

  UserPrivacyInfo({
    required this.snsQuestInfoId,
    required this.isEventAgree,
    required this.isPrivacyAgree,
    required this.name,
    required this.phoneNumber,
    required this.isExposeRank,
    required this.isBadgeTesterMode,
  });

  factory UserPrivacyInfo.fromJson(Map<String, dynamic> json) {
    return UserPrivacyInfo(
      snsQuestInfoId: json['snsQuestInfoId'],
      isPrivacyAgree: json['isPrivacyAgree'],
      isEventAgree: json['isEventAgree'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      isExposeRank: json['isExposeRank'],
      isBadgeTesterMode: json['isBadgeTesterMode'],
    );
  }
}

class UserSession {
  final String sessionId;
  final String snsId;

  UserSession({
    required this.sessionId,
    required this.snsId,
  });
}
