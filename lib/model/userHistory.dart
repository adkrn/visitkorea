class UserHistory {
  final String snsId;
  final String questName;
  final String point;
  final DateTime createDateTimeStamp;

  UserHistory(
      {required this.snsId,
      required this.questName,
      required this.point,
      required this.createDateTimeStamp});

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    return UserHistory(
      snsId: json['snsId'],
      questName: json['questName'],
      point: json['point'].toString(),
      createDateTimeStamp:
          DateTime.fromMillisecondsSinceEpoch(json['createDateTimeStamp']),
    );
  }
}
