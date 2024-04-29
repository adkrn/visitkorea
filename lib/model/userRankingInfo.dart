// 사용자 랭킹전 관련 정보
import 'package:visitkorea/model/quest.dart';

class UserRankingInfo {
  final String rankBoardId;
  final String rankGroupId;
  final RankSNS sns;
  final int ranking;
  final int point;
  Badge_completed? mainBadgeName;
  //String? profileUrl;

  UserRankingInfo({
    required this.rankBoardId,
    required this.rankGroupId,
    required this.sns,
    required this.ranking,
    required this.point,
    this.mainBadgeName,
    //this.profileUrl,
  });

  factory UserRankingInfo.fromJson(Map<String, dynamic> json) {
    return UserRankingInfo(
        rankBoardId: json['rankBoardId'],
        rankGroupId: json['rankGroupId'],
        sns: RankSNS.fromJson(json['sns']),
        ranking: json['ranking'],
        point: json['point']);
  }

  void setMainBadgeName(Badge_completed? badge_completed) {
    mainBadgeName = badge_completed;
  }

  void setProfileUrl(String url) {
    //profileUrl = url;
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
    return RankSNS(snsId: json['snsId'], name: json['name'] ?? '닉네임을 등록해주세요');
  }
}

// 사용자가 속해있는 랭킹 그룹의 정보
// 랭킹확정일, 팝업 노출 여부 등.
class RankGroups {
  final String rankGroupId;
  final String startDate;
  final String endDate;
  final DateTime confirmDate;
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
      confirmDate: DateTime.parse(json['confirmDate']),
      intervalType: json['intervalType'],
      popupYn: json['popupYn'] == 'Y' ? true : false,
      createDate: DateTime.parse(json['createDate']),
    );
  }
}
