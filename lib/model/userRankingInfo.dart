import 'dart:html';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;

class UserRankingInfo {
  final String rankBoardId;
  final String rankGroupId;
  final RankSNS sns;
  final int ranking;
  final int point;
  String? mainBadgeName;
  String? profileUrl;

  UserRankingInfo({
    required this.rankBoardId,
    required this.rankGroupId,
    required this.sns,
    required this.ranking,
    required this.point,
    this.mainBadgeName,
    this.profileUrl,
  });

  factory UserRankingInfo.fromJson(Map<String, dynamic> json) {
    return UserRankingInfo(
        rankBoardId: json['rankBoardId'],
        rankGroupId: json['rankGroupId'],
        sns: RankSNS.fromJson(json['sns']),
        ranking: json['ranking'],
        point: json['point']);
  }

  void setMainBadgeName(String name) {
    mainBadgeName = name;
  }

  void setProfileUrl(String url) {
    profileUrl = url;
  }
}

class RankSNS {
  final String snsId;
  final String name;

  RankSNS({
    required this.snsId,
    required this.name,
  });

  factory RankSNS.fromJson(Map<String, dynamic> json) {
    return RankSNS(snsId: json['snsId'], name: json['name']);
  }
}

class RankGroups {
  final String rankGroupId;
  final String startDate;
  final String endDate;
  final String confirmDate;
  final String intervalType;
  final bool popupYn;
  final DateTime createDate;

  RankGroups(
      {required this.rankGroupId,
      required this.startDate,
      required this.endDate,
      required this.confirmDate,
      required this.intervalType,
      required this.popupYn,
      required this.createDate});

  factory RankGroups.fromJson(Map<String, dynamic> json) {
    return RankGroups(
      rankGroupId: json['rankGroupId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      confirmDate: json['confirmDate'],
      intervalType: json['intervalType'],
      popupYn: json['popupYn'] == 'Y' ? true : false,
      createDate: DateTime.parse(json['createDate']),
    );
  }
}
