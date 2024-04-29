// 퀘스트 타입값
enum QuestType { event, activity, exploer, specificType }

QuestType getQuestType(int questTypeValue) {
  switch (questTypeValue) {
    case 0:
      return QuestType.event;
    case 1:
      return QuestType.activity;
    case 2:
      return QuestType.exploer;
    case 3:
      return QuestType.specificType;
    default:
      throw Exception('Invalid questType value');
  }
}

// 퀘스트 상태값
enum ExposeStatus { waiting, testing, opening }

ExposeStatus getExpseStatus(int exposeStatus) {
  switch (exposeStatus) {
    case 0:
      return ExposeStatus.waiting;
    case 1:
      return ExposeStatus.testing;
    case 2:
      return ExposeStatus.opening;
    default:
      throw Exception('Invalid getExpseStatus value');
  }
}

// 퀘스트 등급값
String getQuestGrade(int gradeValue) {
  switch (gradeValue) {
    case 0:
      return '반복';
    case 1:
      return '초급';
    case 2:
      return '중급';
    case 3:
      return '고급';
    default:
      return '등급이 없습니다';
  }
}

// 퀘스트 진행 상태값
enum ProgressType { unProgressed, progress, completed, receive, expiration }

// 랭킹전 참여 배너 노출 여부
class BannerInfo {
  final String id;
  final bool commonBanner;
  final bool subBanner; // 임시로 서브배너가 추가될 상황에 대비해 미리 만들어놨다고함.

  BannerInfo(
      {required this.id, required this.commonBanner, required this.subBanner});

  factory BannerInfo.fromJson(List<dynamic> json) {
    // 급한대로 임시로 리스트에서 0번째 값 불러오는걸로 처리,
    // 리스트 항목이 늘어날 경우에는 다른 처리가 필요.
    var info = json[0];
    return BannerInfo(
        id: info['id'],
        commonBanner: info['commonBanner'].toString() == 'Y' ? true : false,
        subBanner: info['subBanner'].toString() == 'Y' ? true : false);
  }
}

// 퀘스트 데이터 모델
class Quest {
  final String questSnsId;
  final String snsId;
  final QuestDetails questDetails;
  final int currentCompleteCount;
  final int actionCount;
  bool completed;
  ProgressType progressType;

  Quest({
    required this.questSnsId,
    required this.snsId,
    required this.questDetails,
    required this.currentCompleteCount,
    required this.actionCount,
    required this.completed,
    required this.progressType,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    // 퀘스트 진행 상태를 설정하는 함수
    ProgressType determineProgressType(int actionCount, int actionCountValue,
        bool completed, String startTime, String endTime) {
      double progressRatio = actionCount / actionCountValue;

      DateTime now = DateTime.now();

      if (now.isBefore(DateTime.parse(startTime)) ||
          now.isAfter(DateTime.parse(endTime))) {
        // 기간이 지난 퀘스트는 기간 만료를 띄우기 위해 진행 상태값을 expiration으로 설정.
        return ProgressType.expiration;
      } else {
        if (progressRatio == 0) {
          return ProgressType.unProgressed;
        } else if (progressRatio > 0 && progressRatio < 1) {
          return ProgressType.progress;
        } else if (progressRatio >= 1 && !completed) {
          return ProgressType.completed;
        } else {
          return ProgressType.receive;
        }
      }
    }

    return Quest(
        questSnsId: json['questSnsId'] ?? '',
        snsId: json['snsId'] ?? '',
        questDetails: QuestDetails.fromJson(json['quest'] ?? json),
        currentCompleteCount: json['currentCompleteCount'] ?? 0,
        actionCount: json['actionCount'] ?? 0,
        completed: json['completed'] ?? false,
        progressType: json['actionCount'] != null
            ? determineProgressType(
                json['actionCount'],
                json['quest']['actionCountValue'],
                json['completed'],
                json['quest']['activationStartDate'],
                json['quest']['activationEndDate'])
            : ProgressType.unProgressed);
  }
}

class QuestDetails {
  final String questId;
  final String name;
  final String description;
  final String getMethodDescription;
  final QuestType questType;
  final String grade;
  final String? nextQuestId;
  final QuestActionType questActionType;
  final int actionCountValue;
  final String activationStartDate;
  final String activationEndDate;
  final int checkCycleTime;
  final int repeatCount;
  final Badge_visitKorean? enableBadge;
  final Badge_visitKorean? disableBadge;
  final Badge_visitKorean? unknownBadge;
  final int indexId;
  final int orderIndex;
  final int? questActionTypeDetail;
  final int? questTargetType;
  final int? questTargetTypeValue;
  final int rewardPoint;
  final String conditionName;
  final ExposeStatus exposeStatus;

  QuestDetails({
    required this.questId,
    required this.name,
    required this.description,
    required this.getMethodDescription,
    required this.questType,
    required this.grade,
    this.nextQuestId,
    required this.questActionType,
    required this.actionCountValue,
    required this.activationStartDate,
    required this.activationEndDate,
    required this.checkCycleTime,
    required this.repeatCount,
    this.enableBadge,
    this.disableBadge,
    this.unknownBadge,
    required this.indexId,
    required this.orderIndex,
    required this.questActionTypeDetail,
    required this.questTargetType,
    required this.questTargetTypeValue,
    required this.rewardPoint,
    required this.conditionName,
    required this.exposeStatus,
  });

  factory QuestDetails.fromJson(Map<String, dynamic> json) {
    return QuestDetails(
      questId: json['questId'],
      name: json['name'],
      description: json['description'],
      getMethodDescription: json['getMethodDescription'],
      questType: getQuestType(json['questType']),
      grade: getQuestGrade(json['grade']),
      nextQuestId: json['nextQuestId'],
      questActionType: QuestActionType.fromJson(json['questActionType']),
      actionCountValue: json['actionCountValue'],
      activationStartDate: json['activationStartDate'].toString(),
      activationEndDate: json['activationEndDate'].toString(),
      checkCycleTime: json['checkCycleTime'],
      repeatCount: json['repeatCount'],
      enableBadge: json['enableBadge'] != null
          ? Badge_visitKorean.fromJson(json['enableBadge'])
          : null,
      disableBadge: json['disableBadge'] != null
          ? Badge_visitKorean.fromJson(json['disableBadge'])
          : null,
      unknownBadge: json['unknownBadge'] != null
          ? Badge_visitKorean.fromJson(json['unknownBadge'])
          : null,
      indexId: json['indexId'],
      orderIndex: json['orderIndex'],
      questActionTypeDetail: json['questActionTypeDetail'],
      questTargetType: json['questTargetType'],
      questTargetTypeValue: json['questTargetTypeValue'],
      rewardPoint: json['rewardPoint'],
      conditionName: json['conditionName'],
      exposeStatus: getExpseStatus(
        json['exposeStatus'],
      ),
    );
  }
}

class QuestActionType {
  final String questActionTypeId;
  final String description;
  final int indexId;

  QuestActionType({
    required this.questActionTypeId,
    required this.description,
    required this.indexId,
  });

  factory QuestActionType.fromJson(Map<String, dynamic> json) {
    return QuestActionType(
      questActionTypeId: json['questActionTypeId'],
      description: json['description'],
      indexId: json['indexId'],
    );
  }
}

// 퀘스트 데이터 모델에 쓰이는 배지 데이터
// enable, disable, unknown 배지 데이터는 이 모델로 쓰임.
class Badge_visitKorean {
  final String badgeId;
  final String name;
  final String description;
  final String getMethodDescription;
  final String imgName;
  final int indexId;

  Badge_visitKorean(
      {required this.badgeId,
      required this.name,
      required this.description,
      required this.imgName,
      required this.indexId,
      required this.getMethodDescription});

  factory Badge_visitKorean.fromJson(Map<String, dynamic> json) {
    return Badge_visitKorean(
        badgeId: json['badgeId'],
        name: json['name'],
        description: json['description'],
        imgName: json['imgName'],
        indexId: json['indexId'],
        getMethodDescription: json['getMethodDescription']);
  }
}

// 배지 도감에 쓰이는 배지 데이터 모델
class Badge_completed {
  final String badgeSnsId;
  final Badge_info badgeinfo;
  final String snsId;
  final DateTime createDate;
  ExposeStatus exposeStatus;
  bool isUse;

  Badge_completed({
    required this.badgeSnsId,
    required this.badgeinfo,
    required this.snsId,
    required this.isUse,
    required this.createDate,
    required this.exposeStatus,
  });

  factory Badge_completed.fromJson(Map<String, dynamic> json) {
    return Badge_completed(
        badgeSnsId: json['badgeSnsId'],
        badgeinfo: Badge_info.fromJson(json['badge']),
        snsId: json['snsId'],
        isUse: json['isUse'],
        createDate: DateTime.fromMillisecondsSinceEpoch(json['createDate']),
        exposeStatus: ExposeStatus.opening);
  }
}

class Badge_info {
  final String badgeId;
  final String name;
  final String description;
  final String getMethodDescription;
  final String imgName;
  final int indexId;
  final QuestType badgeType;

  int? rewardPoint;

  Badge_info({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.getMethodDescription,
    required this.imgName,
    required this.indexId,
    required this.badgeType,
  });

  factory Badge_info.fromJson(Map<String, dynamic> json) {
    return Badge_info(
        badgeId: json['badgeId'],
        name: json['name'],
        description: json['description'],
        getMethodDescription: json['getMethodDescription'],
        imgName: json['imgName'],
        indexId: json['indexId'],
        badgeType: getQuestType(json['badgeType']));
  }
}
