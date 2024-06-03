import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:visitkorea/model/userInfo.dart';
import 'package:visitkorea/model/userHistory.dart';
import 'package:visitkorea/model/userRankingInfo.dart';
import 'dart:convert';
import 'model/quest.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'dart:html' as html;

String getDomain() {
  var uri = Uri.parse(html.window.location.href);
  return uri.host;
}

String domain = getDomain();
//'dev.ktovisitkorea.com'
//'121.126.153.150:8080'
//'stage.visitkorea.or.kr'
//'korean.visitkorea.or.kr'

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
    if (_isLoading) return;
    print('퀘스트 로드 시작');
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> queryParameters = {
      'size': '300',
      'page': '0',
    };

    queryParameters['timeStamp'] =
        DateTime.now().millisecondsSinceEpoch.toString();

    var url = Uri.http(
      domain,
      '/quest-api/v1/quest-snses/search',
      queryParameters,
    );

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
        List<dynamic> questsData = jsonResponse['content'] as List<dynamic>;

        List<Quest> filteredQuests =
            questsData.map((data) => Quest.fromJson(data)).toList();

        _questList = filteredQuests;
        if (_questList.isEmpty) {
          print('Quest is Empty');
          _isLoading = false;
          registrationQuest();
        }
        isLogin = true;
        print('Quest Load Success');
        _isLoading = false;
        notifyListeners();
      } else {
        print('Quest Load Fail isLogin false :: Load Empty Quest');
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
    notifyListeners();
  }

  // 퀘스트 진행사항 업데이트
  Future<void> updateQuest(int actionIndex, int actionTypeDetailIndex,
      int targetTypeIndexId, int targetTypeValueIndexId) async {
    if (_isLoading) return;

    print('Quest Update Start');
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(domain, '/quest-api/v1/quest-snses', queryParameters);

    try {
      var response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
        body: json.encode({
          'questActionTypeIndexId': actionIndex,
          "questActionTypeDetailIndexId": actionTypeDetailIndex,
          "questTargetTypeIndexId": targetTypeIndexId,
          "questTargetTypeValueIndexId": targetTypeValueIndexId
        }),
      );
      if (response.statusCode == 200) {
        refreshQuests();
      } else {
        print('Failed to update quests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update quests. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrationQuest() async {
    if (_isLoading) return;

    print('Quest registration Start');
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url =
        Uri.http(domain, '/quest-api/v1/quest-snses/all', queryParameters);

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
      );
      if (response.statusCode == 201) {
        print('Quest registration success');
        refreshQuests();
      } else {
        print(
            'Failed to registration quests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to registration quests. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 퀘스트 진행사항 초기화 (임시기능)
  // 테스트용도로 만들어진 메소드 현재는 사용안함.
  Future<void> initializationQuest() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(
        domain, '/quest-api/v1/quest-snses/initialization', queryParameters);

    try {
      var response = await http.patch(
        url,
        headers: {
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
      );
      if (response.statusCode == 200) {
        refreshQuests();
      } else {
        print('Failed to update quests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update quests. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 배지 수령 처리.
  Future<void> completeQuest(
      BuildContext context, String questSnsId, VoidCallback onSuccess) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(domain, '/quest-api/v1/quest-snses/$questSnsId/complete',
        queryParameters);

    var response = await http.patch(
      url,
      headers: {
        'SNS_ID': '${userSession?.snsId}',
        'Cache-Control': 'no-store',
        'Pragma': 'no-store',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      // 성공적으로 완료 처리. 수령 확인 알림 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              '과제 보상 수령 완료',
              style: TextStyle(fontFamily: 'NotoSansKR'),
            ),
            content: Text('획득한 배지는 배지도감에서\n확인 가능합니다.\n앞으로도 다양한 도전과제에\n참여해보세요!',
                style: TextStyle(fontFamily: 'NotoSansKR')),
            actions: <Widget>[
              TextButton(
                child: Text(
                  '확인',
                  style:
                      TextStyle(color: Colors.blue, fontFamily: 'NotoSansKR'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  onSuccess();
                },
              ),
            ],
          );
        },
      );

      _isLoading = false;
      notifyListeners();
    } else {
      print('Failed to complete quest. Status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmptyQuest() async {
    print('Quest Load Fail Load Empty Quest');
    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };

    var url = Uri.http(
      domain,
      '/quest-api/v1/quests',
      queryParameters,
    );
    try {
      var response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> questsData = jsonResponse as List<dynamic>;

        List<Quest> filteredQuests =
            questsData.map((data) => Quest.fromJson(data)).toList();
        _questList = filteredQuests;
        print('Quest Load Success');
        isLogin = false;
        _isLoading = false;
        notifyListeners();
      } else {
        print('Quest Load Fail Load Empty Quest');
        isLogin = false;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('error : $e');
      isLogin = false;
      _isLoading = false;
      notifyListeners();
    }
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
        print('Failed to load badge. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load badge. Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBadges() async {
    await _fetchBadge();
    notifyListeners();
  }

  Badge_completed getMainBadge() {
    return _badgeList.where((badge) => badge.isUse).single;
  }

  Future<void> setMainBadge(String setBadgeId, VoidCallback onSuccess) async {
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
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
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

Future<void> fetchSession() async {
  Map<String, dynamic> queryParameters = {
    'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
  };

  var url = Uri.http(domain, '/session-api/v1/sessions', queryParameters);

  // 로컬에서 테스트 할때 SNSID 값을 직접 넣어서 테스트.
  userSession = UserSession(
      sessionId: '', snsId: ''); // 16aa6395-6bda-45d1-9111-395e45215249
  // f48926e6-af71-430b-98e5-4909e524e81d
  // b878e5c3-5e6f-43b9-a6dd-05d7571e0f77
  // ef753509-20c7-4f62-9cd1-db407f7a4ba7
  print('snsId Load Start');

  // 사용자 계정 세션에서 snsID를 불러온다.
  try {
    var response = await http.get(
      url,
    );

    if (response.statusCode == 200) {
      print('snsId response Success');
      var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonResponse['snsId']);
      // 세션 ID도 필요하면 설정하려고 설정. 현재는 필요없어서 안쓰고있음.
      if (jsonResponse['snsId'] != null) {
        userSession = UserSession(sessionId: '', snsId: jsonResponse['snsId']);
      }

      print(userSession?.snsId);
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

  Future<void> refreshData(String intervalType) async {
    print('RankingRefreshdataStart');
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    await Future.wait(
        [fatchRankGroups(intervalType), fetchRankingList(intervalType)]);
    _isLoading = false;
    notifyListeners();
    print('RankingRefreshdataEnd');
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

    var url =
        Uri.http(domain, '/quest-api/v1/rank-boards/search', queryParameters);

    print('ranking Load Start');
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
        print('rankingList response Status 200');
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _userList = (jsonResponse['content'] as List)
            .map((data) => UserRankingInfo.fromJson(data))
            .toList();
        for (int i = 0; i < _userList.length; i++) {
          _userList[i]
              .setMainBadgeName(await getMainBadgeName(userList[i].sns.snsId));
        }
      }
    } catch (e) {
      print('ranking Load Fail');
      print('Error: $e');
    }
  }

  Future<void> fatchRankGroups(String intervalType) async {
    Map<String, dynamic> queryParameters = {
      'intervalType': intervalType,
    };

    var url = Uri.http(
        domain, '/quest-api/v1/rank-groups/latest-rank', queryParameters);

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
        _groupsInfo = RankGroups.fromJson(jsonResponse);

        print('rankgroups Load Success');
      }
    } catch (e) {
      print('rankgroups Load Fail');
      print('Error: $e');
    }
  }

  Future<Badge_completed?> getMainBadgeName(String snsId) async {
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
        return badgeComplte;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
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
      } else {
        throw Exception('Network request for image failed');
      }
    } catch (e) {
      print('Error converting image: $e');
      throw Exception('Network request for image failed');
    }
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
        ? DateTime(now.year, now.month + 1, 0)
        : DateTime(now.year + 1, 1, 0);

    var filteredHistoryList = _historyList.where((history) {
      return history.createDateTimeStamp
              .isAfter(startTime.subtract(Duration(days: 1))) &&
          history.createDateTimeStamp.isBefore(lastDay.add(Duration(days: 1)));
    }).toList();

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
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
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
  UserInfo? _userInfo;
  int? _point;
  bool _isLoading = false;

  UserInfo get userInfo => _userInfo!;
  int get userPoint => _point!;
  bool get isLoading => _isLoading;

  UserInfoProvider() {
    fetchUserInfo();
  }

  Future<void> refreshData() async {
    _isLoading = false;
    await fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    var url = Uri.http(domain, '/quest-api/v1/sns-indexes', queryParameters);
    var pointUrl = Uri.http(
        domain, '/quest-api/v1/sns-points/total-point', queryParameters);

    final headers = {
      'SNS_ID': '${userSession?.snsId}',
      'Cache-Control': 'no-store',
      'Pragma': 'no-store',
      'Expires': '0',
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
        print('userinfo 로드 성공');
      }

      if (pointResponse.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(pointResponse.bodyBytes));
        _point = jsonResponse['totalPoint'];
        print('point 로드 성공');
      }
    } catch (e) {
      print('사용자 정보를 찾을 수 없습니다.');
      print('Error $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class UserPrivacyInfoProvider with ChangeNotifier {
  late UserPrivacyInfo _userPrivacyInfo;
  bool _isLoading = false;

  UserPrivacyInfo get userPrivacyInfo => _userPrivacyInfo;
  bool get isLoading => _isLoading;

  // UserPrivacyInfoProvider() {
  //   fetchUserPrivacyInfo();
  // }

  Future<void> refreshData() async {
    _isLoading = false;
    await fetchUserPrivacyInfo();
    //notifyListeners();
  }

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
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _userPrivacyInfo = UserPrivacyInfo.fromJson(jsonResponse);
        print('로드 성공');
        _isLoading = false;
        notifyListeners();
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
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자 개인정보 등록
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
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
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
          'Content-Type': 'application/json',
          'SNS_ID': '${userSession?.snsId}',
          'Cache-Control': 'no-store',
          'Pragma': 'no-store',
          'Expires': '0',
        },
        body: json.encode({
          "isPrivacyAgree": info.isPrivacyAgree,
          "name": info.name,
          "phoneNumber": info.phoneNumber
        }),
      );
      if (response.statusCode == 200) {
        refreshData();
        print('Success to update userPrivacyInfo');
        _isLoading = false;
        notifyListeners();
        onSucsses();
      } else {
        print(
            'Failed to update userPrivacyInfo. StatusCode: ${response.statusCode}');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update userPrivacyInfo. Error: $e');
      _isLoading = false;
      notifyListeners();
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
    notifyListeners();

    Map<String, dynamic> queryParameters = {
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    var url = Uri.http(domain, '/quest-api/v1/event-banners', queryParameters);

    final headers = {
      'Cache-Control': 'no-store',
      'Pragma': 'no-store',
      'Expires': '0',
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        _bannerInfo = BannerInfo.fromJson(jsonResponse);
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('EventBannerInfo Load Error $e');
      _bannerInfo = BannerInfo(id: '', commonBanner: false, subBanner: false);
      _isLoading = false;
      notifyListeners();
    }
  }
}
