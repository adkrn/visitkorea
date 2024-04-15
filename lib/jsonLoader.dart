import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visitkorea/model/testUserInfo.dart';
import 'package:visitkorea/model/userInfo.dart';
import 'package:visitkorea/model/userSession.dart';
import 'package:visitkorea/model/userHistory.dart';
import 'package:visitkorea/model/userRankingInfo.dart';
import 'dart:convert';
import 'model/quest.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:flutter/cupertino.dart';

String domain = '121.126.153.150:8080';
//'dev.ktovisitkorea.com'
//'121.126.153.150:8080'
//'stage.visitkorea.or.kr'

class QuestProvider with ChangeNotifier {
  List<Quest> _questList = [];
  bool _isLoading = false;
  List<Quest> get questList => _questList;
  bool isLogin = false;

  bool get isLoading => _isLoading;

  QuestProvider() {
    fetchQuest();
  }

  Future<void> fetchQuest({
    int questActionTypeIndexId = 999,
    int questType = 99,
    int activationStartDateTimeStamp = 2024,
    int activationEndDateTimeStamp = 2999,
  }) async {
    if (_isLoading) return; // 이미 데이터 로딩 중이라면 중복 실행 방지, 빈 리스트 반환
    print('퀘스트 로드 시작');
    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트
    Map<String, dynamic> queryParameters = {
      'size': '300',
      'page': '0',
    };

    // // 파라미터 값이 기본값이 아니면 쿼리 파라미터에 추가
    // if (questActionTypeIndexId != 999) {
    //   queryParameters['questActionTypeIndexId'] =
    //       questActionTypeIndexId.toString();
    // }
    // if (questType != 99) {
    //   queryParameters['questType'] = questType.toString();
    // }
    switch (activationStartDateTimeStamp) {
      case 2024:
        queryParameters['activationStartDateTimeStamp'] = '1704067200';
      case 2025:
        queryParameters['activationStartDateTimeStamp'] = '1735689600000';
      case 2026:
        queryParameters['activationStartDateTimeStamp'] = '1767225600000';
    }

    switch (activationEndDateTimeStamp) {
      case 2025:
        queryParameters['activationEndDateTimeStamp'] = '1735689600000';
      case 2026:
        queryParameters['activationEndDateTimeStamp'] = '1767225600000';
      case 2999:
        break;
    }

    queryParameters['timeStamp'] =
        DateTime.now().millisecondsSinceEpoch.toString();

    // 개발계에 올릴때 domain으로 수정해야함.
    var url = Uri.http(
      domain,
      '/quest-api/v1/quest-snses/search',
      queryParameters,
    );

    print('Quest Load Start');
    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> questsData = jsonResponse['content'] as List<dynamic>;

        List<Quest> filteredQuests = questsData
            .map((data) => Quest.fromJson(data))
            // .where((quest) =>
            //     quest.questDetails.questType !=
            //     QuestType
            //         .specificType) // QuestType.specificType은 3에 해당하는 enum값으로 가정
            .toList();

        // 이후 로직에서는 filteredQuests 리스트를 사용
        _questList = filteredQuests;
        if (_questList.isEmpty) {
          print('Quest is Empty');
          _isLoading = false;
          registrationQuest();
        }
        isLogin = true;
        print('Quest Load Success');
        _isLoading = false;
        notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
      } else {
        print('Quest Load Fail Load Empty Quest');
        loadEmptyQuest();
      }
    } catch (e) {
      print('error : $e');
      loadEmptyQuest();
    }
  }

  // 퀘스트 리스트 리프레쉬
  Future<void> refreshQuests() async {
    _isLoading = false;
    await fetchQuest();
    notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
  }

  // 퀘스트 진행사항 업데이트
  Future<void> updateQuest(int actionIndex, int actionTypeDetailIndex,
      int targetTypeIndexId, int targetTypeValueIndexId) async {
    if (_isLoading) return; // 이미 데이터 로딩 중이라면 중복 실행 방지

    print('Quest Update Start');
    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    //var url =
    //     Uri.parse('https://dev.ktovisitkorea.com/quest-api/v1/quest-snses');
    //var url = Uri.parse('http://121.126.153.150:8080/quest-api/v1/quest-snses');
    var url = Uri.http(domain, '/quest-api/v1/quest-snses', queryParameters);

    try {
      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json', // 내용 형식 JSON으로 설정
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
        body: json.encode({
          'questActionTypeIndexId': actionIndex,
          "questActionTypeDetailIndexId": actionTypeDetailIndex,
          "questTargetTypeIndexId": targetTypeIndexId,
          "questTargetTypeValueIndexId": targetTypeValueIndexId
        }), // body를 JSON 문자열로 변환
      );
      if (response.statusCode == 200) {
        refreshQuests(); // 데이터를 새로고침
      } else {
        print('Failed to update quests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('Failed to update quests. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
    }
  }

  Future<void> registrationQuest() async {
    if (_isLoading) return;

    print('Quest registration Start');
    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url =
        Uri.http(domain, '/quest-api/v1/quest-snses/all', queryParameters);

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // 내용 형식 JSON으로 설정
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        }, // body를 JSON 문자열로 변환
      );
      if (response.statusCode == 201) {
        print('Quest registration success');
        refreshQuests(); // 데이터를 새로고침
      } else {
        print(
            'Failed to registration quests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('Failed to registration quests. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
    }
  }

  // 퀘스트 진행사항 초기화 (임시기능)
  Future<void> initializationQuest() async {
    if (_isLoading) return; // 이미 데이터 로딩 중이라면 중복 실행 방지

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    // var url = Uri.parse(
    //     'https://dev.ktovisitkorea.com/quest-api/v1/quest-snses/initialization');

    var url = Uri.http(
        domain, '/quest-api/v1/quest-snses/initialization', queryParameters);

    try {
      var response = await http.patch(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        }, // body를 JSON 문자열로 변환
      );
      if (response.statusCode == 200) {
        refreshQuests(); // 데이터를 새로고침
      } else {
        print('Failed to update quests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('Failed to update quests. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
    }
  }

  // 배지 수령 처리.
  Future<void> completeQuest(
      BuildContext context, String questSnsId, VoidCallback onSuccess) async {
    if (_isLoading) return; // 이미 데이터 로딩 중이라면 중복 실행 방지

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(domain, '/quest-api/v1/quest-snses/$questSnsId/complete',
        queryParameters);

    var response = await http.patch(
      url,
      headers: {
        'SNS_ID': '${userSession?.snsId}',
        'Cache-Control': 'no-store', // 캐시 방지
        'Pragma': 'no-store', // 캐시 방지
        'Expires': '0', // 캐시 방지
      },
    );

    if (response.statusCode == 200) {
      // 성공적으로 완료 처리. 수령 확인 알림 표시
      showDialog(
        context: context,
        barrierDismissible: false, // 사용자가 다이얼로그 바깥을 탭해도 닫히지 않도록 설정
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('과제 보상 수령 완료'),
            content: Text('획득한 배지는 배지도감에서\n확인 가능합니다.\n앞으로도 다양한 도전과제에\n참여해보세요!'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  '확인',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // 알럿 닫기
                  Navigator.of(context).pop(); // 팝업 닫기
                  onSuccess();
                },
              ),
            ],
          );
        },
      );

      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    } else {
      // 오류 내용 출력
      print('Failed to complete quest. Status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }

  // 임시로 만든 VIP 배지 수령 처리
  Future<void> completeVIPQuest() async {
    if (_isLoading) return; // 이미 데이터 로딩 중이라면 중복 실행 방지

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    List<Quest> qusetSNSIDList = questList
        .where(
            (quest) => quest.questDetails.questType == QuestType.specificType)
        .toList();

    var urlList = [];

    for (int i = 0; i < qusetSNSIDList.length; i++) {
      if (qusetSNSIDList[i].completed == false) {
        urlList.add(Uri.http(
            domain,
            '/quest-api/v1/quest-snses/${qusetSNSIDList[i].questSnsId}/complete',
            queryParameters));
      }
    }

    if (urlList.isEmpty) return;

    final headers = {
      'SNS_ID': '${userSession?.snsId}',
      'Cache-Control': 'no-store', // 캐시 방지
      'Pragma': 'no-store', // 캐시 방지
      'Expires': '0', // 캐시 방지
    };

    try {
      var responses = await Future.wait([
        for (int i = 0; i < urlList.length; i++) ...[
          http.patch(urlList[i], headers: headers)
        ]
      ]);

      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          print('$i 퀘스트 완료 처리 성공');
        } else {
          print('$i 실패');
        }
      }
    } catch (e) {
      print('VIP 배지 완료 처리를 성공하지 못했습니다');
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }

  Future<void> loadEmptyQuest() async {
    // 네트워크 오류 처리
    print('Quest Load Fail Load Empty Quest');
    // 비로그인 상태.
    var jsonString = await rootBundle.loadString('assets/quest.json');
    var jsonResponse = jsonDecode(jsonString);
    _questList = (jsonResponse['content'] as List)
        .map((data) => Quest.fromJson(data))
        .toList();
    isLogin = false;
    _isLoading = false;
    notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
  }
}

class BadgeProvider with ChangeNotifier {
  List<Badge_completed> _badgeList = [];
  bool _isLoading = false;
  bool isSetMainBadge = false;

  List<Badge_completed> get badgeList => _badgeList;

  bool get isLoading => _isLoading;

  BadgeProvider() {
    _fetchBadge();
  }

  Future<void> _fetchBadge() async {
    if (_isLoading) return; // 이미 데이터 로딩 중이라면 중복 실행 방지

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'size': '300',
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    // var url = Uri.parse(
    //     'https://dev.ktovisitkorea.com/quest-api/v1/badge-snses/search?size=300');

    // 개발계에 올릴때 domain으로 수정해야됨.
    var url =
        Uri.http(domain, '/quest-api/v1/badge-snses/search', queryParameters);
    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _badgeList = (jsonResponse['content'] as List)
            .map((data) => Badge_completed.fromJson(data))
            .toList();

        // 획득순으로 정렬
        _badgeList.sort((a, b) => a.createDate.compareTo(b.createDate));

        // 대표배지가 설정되있는지 확인하고 정보 가져오기.
        try {
          mainBadge = getMainBadge();
          isSetMainBadge = true;
          print('설정된 메인배지가 있습니다.');
        } catch (e) {
          isSetMainBadge = false;
          print('설정된 메인배지가 없습니다.');
        }
      } else {
        // 에러 처리 로직 추가
        print('Failed to load badge. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('Failed to load badge. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
    }
  }

  Future<void> refreshBadges() async {
    await _fetchBadge();
    notifyListeners(); // 데이터 로딩 상태 및 데이터 업데이트
  }

  Badge_completed getMainBadge() {
    //refreshBadges();
    return _badgeList.where((badge) => badge.isUse).single;
  }

  Future<void> setMainBadge(String setBadgeId, VoidCallback onSuccess) async {
    // var url = Uri.parse(
    //     'https://dev.ktovisitkorea.com/quest-api/v1/badge-snses/${setBadgeId}/main');

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(domain, '/quest-api/v1/badge-snses/${setBadgeId}/main',
        queryParameters);

    try {
      await http.post(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
      );

      // 데이터를 새로고침하고, onSuccess 콜백을 Future.microtask를 사용하여 연기합니다.
      Future.microtask(() {
        refreshBadges();
        onSuccess();
        print('대표배지 설정 성공');
      });
    } catch (e) {
      print('Failed to load quests. Error: $e');
    }
  }
}

Future<List<Quest>> fetchEmptyQuest() async {
  String jsonString = await rootBundle.loadString('assets/quest.json');
  Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
  List<dynamic> content = jsonResponse['content'];

  return content.map<Quest>((json) => Quest.fromJson(json)).toList();
}

// var response = await http.get(
//   url,
//   headers: {'SNS_ID': '${selectUser?.snsId}'},
// );

Future<void> fetchSession() async {
  Map<String, dynamic> queryParameters = {
    'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
  };

  var url = Uri.http(domain, '/session-api/v1/sessions', queryParameters);
  print('$domain/rewardPage/');

  userSession = UserSession(
      sessionId: '',
      snsId:
          '16aa6395-6bda-45d1-9111-395e45215249'); // 16aa6395-6bda-45d1-9111-395e45215249
  print(userSession?.snsId);
  // f48926e6-af71-430b-98e5-4909e524e81d
  // b878e5c3-5e6f-43b9-a6dd-05d7571e0f77
  // ef753509-20c7-4f62-9cd1-db407f7a4ba7
  print('snsId Load Start');
  try {
    var response = await http.get(
      url,
    );

    if (response.statusCode == 200) {
      print('snsId response Success');
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonResponse['snsId']);
      userSession = UserSession(sessionId: '', snsId: jsonResponse['snsId']!);
      print(userSession?.snsId);
      print('sessionId Load Start');

      var url = Uri.http('https://$domain');
      final cookieResponse = await http.get(url);

      String? setCookie = cookieResponse.headers['set-cookie'];
      print('setCookie Check Start ::: $setCookie');

      if (setCookie != null) {
        print('setCookie != null');
        final RegExp regExp = RegExp(r'JSESSIONID=([^;]+)');
        final match = regExp.firstMatch(setCookie);
        var sessionId = match?.group(1);

        userSession =
            UserSession(sessionId: sessionId!, snsId: jsonResponse['snsId']);
        print('sessionId response Success');
        print('Session ID: $sessionId');
      }
    }
  } catch (e) {
    print('Failed to Load SessionInfo Error : $e');
  }
}

class RankingProvider with ChangeNotifier {
  List<UserRankingInfo> _userList = [];
  late RankGroups _groupsInfo;

  bool _isLoading = false;
  List<UserRankingInfo> get userList => _userList;
  RankGroups get groupsInfo => _groupsInfo;

  bool get isLoading => _isLoading;

  // RankingProvider() {
  //   refreshData('M');
  // }

  Future<void> refreshData(String intervalType) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    await Future.wait(
        [fatchRankGroups(intervalType), fetchRankingList(intervalType)]);
    _isLoading = false;
    notifyListeners();
  }

  UserRankingInfo? getThisUser(String snsId) {
    try {
      return _userList.firstWhere((user) => user.sns.snsId == snsId);
    } catch (e) {
      // 일치하는 사용자가 없는 경우
      return null;
    }
  }

  Future<void> fetchRankingList(String intervalType) async {
    Map<String, dynamic> queryParameters = {
      'intervalType': intervalType,
      'page': '0',
      'size': '100',
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    // var url = Uri.https('dev.ktovisitkorea.com',
    //     '/quest-api/v1/sns-point-ranks', queryParameters);

    // 개발계 올리기전에 dev로 경로 수정해야함.
    var url =
        Uri.http(domain, '/quest-api/v1/rank-boards/search', queryParameters);

    print('ranking Load Start');
    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _userList = (jsonResponse['content'] as List)
            .map((data) => UserRankingInfo.fromJson(data))
            .toList();
        print('ranking Load Success');

        _userList.sort((a, b) => a.ranking.compareTo(b.ranking));
        for (int i = 0; i < _userList.length; i++) {
          _userList[i]
              .setMainBadgeName(await getMainBadgeName(userList[i].sns.snsId));
          _userList[i]
              .setProfileUrl(await getProfileUrl(userList[i].sns.snsId));
        }
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('ranking Load Fail');
      print('Error: $e');
    }
  }

  Future<void> fatchRankGroups(String intervalType) async {
    Map<String, dynamic> queryParameters = {
      'intervalType': intervalType,
    };

    // 개발계 올리기전에 dev로 경로 수정해야함.
    var url = Uri.http(
        domain, '/quest-api/v1/rank-groups/latest-rank', queryParameters);

    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _groupsInfo = RankGroups.fromJson(jsonResponse);

        print('rankgroups Load Success');
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('rankgroups Load Fail');
      print('Error: $e');
    }
  }

  Future<String> getMainBadgeName(String snsId) async {
    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url =
        Uri.http(domain, '/quest-api/v1/badge-snses/main', queryParameters);

    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': snsId,
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        Badge_completed badgeComplte = (Badge_completed.fromJson(jsonResponse));
        return badgeComplte.badgeinfo.name;
      }
    } catch (e) {
      //print('Failed to load MainBadge. Error: $e');
      //print('해당 유저는 메인 배지가 설정되어 있지 않습니다.');
    }
    return '';
  }

  Future<String> getProfileUrl(String snsId) async {
    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(domain, '/quest-api/v1/snses/image', queryParameters);

    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': snsId,
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      //print('Failed to load MainBadge. Error: $e');
      //print('해당 유저는 메인 배지가 설정되어 있지 않습니다.');
    }
    return '';
  }
}

class UserHistoryProvider with ChangeNotifier {
  late List<UserHistory> _historyList;
  bool _isLoading = false;

  List<UserHistory> get historyList => _historyList;
  bool get isLoading => _isLoading;

  UserHistoryProvider() {
    fetchUserHistory('M');
  }

  Future<void> refreshData(String interval) async {
    _isLoading = false;
    await fetchUserHistory(interval);
    notifyListeners();
  }

  void setTimeStamp(String intervalType) {
    DateTime now = DateTime.now();
    DateTime startTime = intervalType == 'M'
        ? DateTime(now.year, now.month, 1)
        : DateTime(now.year, 1, 1);
    DateTime lastDay = intervalType == 'M'
        ? DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1))
        : DateTime(now.year + 1, 1, 1).subtract(Duration(days: 1));

    // 조건에 맞는 항목만 필터링하여 새 리스트를 생성
    var filteredHistoryList = _historyList.where((history) {
      // createTime이 startTime과 lastDay 사이인지 확인
      return history.createDateTimeStamp.isAfter(startTime) &&
          history.createDateTimeStamp.isBefore(lastDay);
    }).toList();

    // _historyList를 필터링된 리스트로 업데이트
    _historyList = filteredHistoryList;
  }

  Future<void> fetchUserHistory(String interval) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'snsId': '${userSession?.snsId}',
      'size': '100',
      'page': '0',
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(
        domain, '/quest-api/v1/sns-point-logs/search', queryParameters);

    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _historyList = (jsonResponse['content'] as List)
            .map((data) => UserHistory.fromJson(data))
            .toList();
        print('history List Load Success');
        setTimeStamp(interval);
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('history List Load Fail');
      print('Error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<UserHistory>> _fetchUserHistory() async {
    String jsonString =
        await rootBundle.loadString('assets/userHistoryText.json');
    Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
    List<dynamic> content = jsonResponse['content'];

    return content
        .map<UserHistory>((json) => UserHistory.fromJson(json))
        .toList();
  }
}

class UserInfoProvider with ChangeNotifier {
  late UserInfo _userInfo;
  late int _point;
  bool _isLoading = false;

  UserInfo get userInfo => _userInfo;
  int get userPoint => _point;
  bool get isLoading => _isLoading;

  UserInfoProvider() {
    _fetchUserInfo();
  }

  Future<void> refreshData() async {
    _isLoading = false;
    await _fetchUserInfo();
    notifyListeners();
  }

  Future<void> _fetchUserInfo() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    var url = Uri.http(domain, '/quest-api/v1/sns-indexes', queryParameters);
    var pointUrl = Uri.http(
        domain, '/quest-api/v1/sns-points/total-point', queryParameters);

    final headers = {
      'SNS_ID': '${userSession?.snsId}',
      'Cache-Control': 'no-store', // 캐시 방지
      'Pragma': 'no-store', // 캐시 방지
      'Expires': '0', // 캐시 방지
    };

    try {
      // 두 요청을 동시에 실행합니다.
      final responses = await Future.wait([
        http.get(url, headers: headers),
        http.get(pointUrl, headers: headers),
      ]);

      final response = responses[0];
      final pointResponse = responses[1];

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _userInfo = UserInfo.fromJson(jsonResponse);
      }

      if (pointResponse.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(pointResponse.bodyBytes));
        _point = jsonResponse['totalPoint'];
      }
    } catch (e) {
      print('사용자 정보를 찾을 수 없습니다.');
      print('Error $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }
}

class UserPrivacyInfoProvider with ChangeNotifier {
  late UserPrivacyInfo _userPrivacyInfo;
  bool _isLoading = false;

  UserPrivacyInfo get userPrivacyInfo => _userPrivacyInfo;
  bool get isLoading => _isLoading;

  UserPrivacyInfoProvider() {
    fetchUserPrivacyInfo();
  }

  Future<void> refreshData() async {
    _isLoading = false;
    await fetchUserPrivacyInfo();
    notifyListeners();
  }

  /// 사용자 개인정보 조회
  ///
  /// Get http://dev.ktovisitkorea.com/quest-api/v1/sns-quest-infos
  Future<void> fetchUserPrivacyInfo() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url =
        Uri.http(domain, '/quest-api/v1/sns-quest-infos', queryParameters);

    try {
      var response = await http.get(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _userPrivacyInfo = UserPrivacyInfo.fromJson(jsonResponse);
        print('로드 성공');
        _isLoading = false;
        notifyListeners(); // 로딩 상태 업데이트
      } else {
        if (userSession != null) {
          _isLoading = false;
          createData();
        }
      }
    } catch (e) {
      print('Error $e');
      _userPrivacyInfo = UserPrivacyInfo(
        snsQuestInfoId: '',
        isEventAgree: false,
        isPrivacyAgree: false,
        name: '',
        phoneNumber: '',
        isExposeRank: false,
        isBadgeTesterMode: false,
      );
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    } finally {
      // _userPrivacyInfo = UserPrivacyInfo(
      //   snsQuestInfoId: '',
      //   isEventAgree: false,
      //   isPrivacyAgree: false,
      //   name: '',
      //   phoneNumber: '',
      //   isExposeRank: false,
      //   isBadgeTesterMode: false,
      // );
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }

  /// 사용자 개인정보 등록
  ///
  /// Post http://dev.ktovisitkorea.com/quest-api/v1/sns-quest-infos
  Future<void> createData() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url =
        Uri.http(domain, '/quest-api/v1/sns-quest-infos', queryParameters);

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
        body: json.encode({
          'Content-Type': 'application/json',
          "isEventAgree": true,
          "isPrivacyAgree": false,
          "name": null,
          "phoneNumber": null,
        }),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _userPrivacyInfo = UserPrivacyInfo.fromJson(jsonResponse);
        print('Success to create userPrivacyInfo.');
        _isLoading = false;
        refreshData();
      }
    } catch (e) {
      print('Failed to create userPrivacyInfo. Error: $e');
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }

  /// 사용자 개인정보 수정
  ///
  /// Patch http://dev.ktovisitkorea.com/quest-api/v1/sns-quest-infos
  Future<void> updateData(UserPrivacyInfo info, VoidCallback onSucsses) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(
        domain,
        '/quest-api/v1/sns-quest-infos/${_userPrivacyInfo.snsQuestInfoId}',
        queryParameters);

    try {
      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json', // 내용 형식 JSON으로 설정
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store', // 캐시 방지
          'Pragma': 'no-store', // 캐시 방지
          'Expires': '0', // 캐시 방지
        },
        body: json.encode({
          "isPrivacyAgree": info.isPrivacyAgree,
          "name": info.name,
          "phoneNumber": info.phoneNumber
        }), // body를 JSON 문자열로 변환
      );
      if (response.statusCode == 200) {
        refreshData(); // 데이터를 새로고침
        print('Success to update userPrivacyInfo');
        _isLoading = false;
        notifyListeners(); // 로딩 상태 업데이트
        onSucsses();
      } else {
        print(
            'Failed to update userPrivacyInfo. StatusCode: ${response.statusCode}');
        _isLoading = false;
        notifyListeners(); // 로딩 상태 업데이트
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('Failed to update userPrivacyInfo. Error: $e');
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }
}

class EventBannerProvider with ChangeNotifier {
  late BannerInfo _bannerInfo;
  bool _isLoading = false;

  BannerInfo get bannerInfo => _bannerInfo;
  bool get isLoading => _isLoading;

  EventBannerProvider() {
    _fetchBannerInfo();
  }

  Future<void> refreshData() async {
    _isLoading = false;
    await _fetchBannerInfo();
    notifyListeners();
  }

  Future<void> _fetchBannerInfo() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners(); // 로딩 상태 업데이트

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    var url = Uri.http(domain, '/quest-api/v1/event-banners', queryParameters);

    final headers = {
      'Cache-Control': 'no-store', // 캐시 방지
      'Pragma': 'no-store', // 캐시 방지
      'Expires': '0', // 캐시 방지
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _bannerInfo = BannerInfo.fromJson(jsonResponse);
        _isLoading = false;
        notifyListeners(); // 로딩 상태 업데이트
      }
    } catch (e) {
      print('EventBannerInfo Load Error $e');
      _bannerInfo = BannerInfo(id: '', commonBanner: false, subBanner: false);
      _isLoading = false;
      notifyListeners(); // 로딩 상태 업데이트
    }
  }
}

Future<List<TestUser>> fetchTestUserList() async {
  String jsonString = await rootBundle.loadString('assets/testUserTable.json');
  Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
  List<dynamic> content = jsonResponse['content'];

  return content.map<TestUser>((json) => TestUser.fromJson(json)).toList();
}
