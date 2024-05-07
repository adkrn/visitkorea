import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitkorea/jsonLoader.dart';
import 'package:visitkorea/model/quest.dart';
import 'package:visitkorea/model/userInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:visitkorea/popup/questInfoPopup.dart';
import 'mobile_view.dart';
import 'desktop_view.dart';
import '../common_widgets.dart';
import 'package:collection/collection.dart';
import '../main.dart';
import '../activityHistory/userActivityHistory.dart';
import '../rankingListpage/rankingListPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitkorea/myBadgeCollections/myBadgeCollections.dart';
import 'dart:js' as js;

const String _baseUrl = 'assets/';
late UserPrivacyInfoProvider provider;

List<String> dropdownValuelist = <String>['2024년'];

Map<String, List<String>> dropDownValuelist = {
  '이벤트': dropdownValuelist,
  '일반활동': dropdownValuelist
};

Map<String, String> dropDownValueQuestType = {
  '이벤트': '2024년',
  '일반활동': '2024년',
};
String getQuestSectionTitleByType(QuestType type) {
  switch (type) {
    case QuestType.event:
      return '이벤트';
    case QuestType.activity:
      return '일반활동';
    case QuestType.exploer:
      return '전국탐방';
    case QuestType.specificType:
      return '';
  }
}

class QuestListPage extends StatefulWidget {
  @override
  _QuestListPageState createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage> {
  bool _isProviderInitialized = false;

  @override
  void didChangeDependencies() {
    print('didChangeDependencies Start');
    super.didChangeDependencies();
    if (!_isProviderInitialized) {
      provider = Provider.of<UserPrivacyInfoProvider>(context, listen: false);
    }
    print('didChangeDependencies End');
  }

  @override
  void initState() {
    print('initState Start');
    super.initState();

    Future.microtask(() async {
      await provider.refreshData();

      setState(() {
        _isProviderInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(appBarHeight: isMobile ? 98 : 90),
        body: isMobile ? MobileLayout_questList() : DesktopLayout_questList());
  }
}

void redirectToUrl(String url) {
  js.context.callMethod('open', [url, '_self']);
}

List<Quest> filterQuests(List<Quest> quests, List<Badge_completed> badges) {
  List<Quest> filterQuest = List.from(quests);

  for (var quest in quests) {
    // 배지를 수령 완료한 퀘스트일때, 다음 등급의 퀘스트가 존재 하면 리스트에서 삭제
    if (quest.progressType == ProgressType.receive) {
      try {
        var badge = badges.firstWhere((badge) =>
            badge.badgeinfo.badgeId == quest.questDetails.enableBadge?.badgeId);

        badge.badgeinfo.rewardPoint = quest.questDetails.rewardPoint;
      } catch (e) {
        //print('퀘스트 완료안했는데 배지 보유중');
      }

      if (quest.questDetails.nextQuestId != null) {
        filterQuest.remove(quest);
      }
    } else {
      // 대기중인 퀘스트는 리스트에서 삭제.
      if (quest.questDetails.exposeStatus == ExposeStatus.waiting) {
        filterQuest.remove(quest);
      }

      // 배지 수령이 안된 퀘스트들은 다음 등급의 퀘스트들이 노출되면 안된다.
      if (quest.questDetails.nextQuestId != null) {
        //print('${quest.questDetails.nextQuestId} 다음 등급 퀘스트가 있음');
        _removeNextGradeQuests(
            filterQuest, quests, quest.questDetails.nextQuestId);
      }
    }
  }

  filterQuest.sort(
      (a, b) => a.questDetails.orderIndex.compareTo(b.questDetails.orderIndex));
  return filterQuest;
}

/// 다음 등급의 퀘스트들을 리스트에서 제거합니다.
void _removeNextGradeQuests(
    List<Quest> filterQuest, List<Quest> quests, String? nextQuestId) {
  if (nextQuestId == null) return;

  var nQuest =
      quests.singleWhereOrNull((e) => e.questDetails.questId == nextQuestId);
  filterQuest.remove(nQuest);

  _removeNextGradeQuests(filterQuest, quests, nQuest?.questDetails.nextQuestId);
}

Widget getQuestImageByProgressType(BuildContext context, Quest quest,
    {double imageWidth = 90, double imageHeight = 90}) {
  ProgressType progressType = quest.progressType;

  String getImageUrl(ProgressType type) {
    switch (type) {
      case ProgressType.unProgressed:
        if (quest.questDetails.grade == '반복') {
          if (quest.questDetails.conditionName == '대구석VIP 달성하기') {
            return '${_baseUrl}unknown/${quest.questDetails.unknownBadge!.imgName}.png';
          } else {
            return '${_baseUrl}enable/${quest.questDetails.unknownBadge!.imgName}.png';
          }
        } else {
          return '${_baseUrl}unknown/${quest.questDetails.unknownBadge!.imgName}.png';
        }
      case ProgressType.progress:
        if (quest.questDetails.grade == '반복') {
          return '${_baseUrl}enable/${quest.questDetails.disableBadge!.imgName}.png';
        } else {
          return '${_baseUrl}disable/${quest.questDetails.disableBadge!.imgName}.png';
        }
      case ProgressType.completed:
        return '${_baseUrl}enable/${quest.questDetails.enableBadge!.imgName}.png';
      case ProgressType.receive:
        return '${_baseUrl}enable/${quest.questDetails.enableBadge!.imgName}.png';
      case ProgressType.expiration:
        return '${_baseUrl}disable/${quest.questDetails.disableBadge!.imgName}.png';
      default:
        throw Exception('잘못된 퀘스트 정보입니다.');
    }
  }

  String imageUrl = getImageUrl(progressType);
  double progress = quest.actionCount / quest.questDetails.actionCountValue;
  DateTime now = DateTime.now();

  //print('ImageSize : $imageWidth , $imageHeight');
  return InkWell(
      onTap: () => showQuestPopup(context, quest),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (progressType != ProgressType.receive) ...[
            Image.asset(
              imageUrl, // 서버에 저장된 이미지 URL
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain, // 이미지 적절히 조정
            ),
            SizedBox(
              width: imageWidth,
              height: imageHeight,
              child: CircularProgressIndicator(
                value: progress, // 진행율 설정
                backgroundColor: const Color(0xffD6D6D6), // 배경 색상
                color: const Color(0xff5869FF), // 진행 색상
                strokeWidth: 5,
              ),
            ),
            // 퀘스트 완료 후 배지 수령 전 상태
            if (progressType == ProgressType.completed)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/questComplted.png',
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                  buildText(
                    quest.questDetails.grade == '반복' ? '보상수령' : '배지 수령',
                    TextType.h6,
                    textColor: Colors.white,
                  )
                ],
              ),
            // 기간 만료
            if (now
                .isAfter(DateTime.parse(quest.questDetails.activationEndDate)))
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/icon_Ellipse.png',
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                  buildText(
                    '기간 만료',
                    TextType.h6,
                    textColor: Colors.white,
                  )
                ],
              ),
          ] else ...[
            Image.asset(
              imageUrl, // 서버에 저장된 이미지 URL
              width: 109,
              height: imageHeight,
              fit: BoxFit.fitWidth, // 이미지 적절히 조정
            ),
          ]
        ],
      ));
}

void launchURL() async {
  var url = Uri.http(
      'https://$domain', '/common/login.do'); // 여기에 원하는 웹페이지 주소를 입력하세요.
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

void showRankAlert(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text(
          '랭킹전',
          style: TextStyle(fontFamily: 'NotoSansKR'),
        ),
        content: SingleChildScrollView(
          // 내용이 길어질 수 있으므로 SingleChildScrollView 사용
          child: ListBody(
            // ListBody를 사용하여 자식들이 수직으로 배치되도록 함
            children: <Widget>[
              Text(message, style: TextStyle(fontFamily: 'NotoSansKR')),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('확인',
                style: TextStyle(color: Colors.blue, fontFamily: 'NotoSansKR')),
            onPressed: () {
              Navigator.of(context).pop(); // 대화상자 닫기
            },
          ),
        ],
      );
    },
  );
}

void buildRankPopup(BuildContext context) {
  bool isMobile = MediaQuery.of(context).size.width < 910;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Center(
            child: Container(
              width: isMobile ? 358 : 600,
              height: 170,
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildText('배지콕콕 랭킹전', TextType.h4),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFFDDDDDD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildText('랭킹 공개 전입니다.', TextType.p16R),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xFF001941)),
                        fixedSize: MaterialStatePropertyAll(Size(155, 42)),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(3)), // 모서리를 사각형으로 설정
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        child: buildText(
                          '확인',
                          TextType.p16M,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showNonLoginAlertDialog(BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text(
        '알림',
        style: TextStyle(fontFamily: 'NotoSansKR'),
      ),
      content: const Text('로그인이 필요한 서비스입니다',
          style: TextStyle(fontFamily: 'NotoSansKR')),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            String url =
                'https://$domain/common/login.do'; // 여기에 원하는 웹페이지 주소를 입력하세요.
            redirectToUrl(url);
            Navigator.pop(context);
          },
          child: const Text('확인',
              style: TextStyle(color: Colors.blue, fontFamily: 'NotoSansKR')),
        ),
      ],
    ),
  );
}

void showUserInfoAgreementCancelPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return UserInfoAgreementCancelPopup();
    },
  );
}

class UserInfoAgreementCancelPopup extends StatefulWidget {
  @override
  _UserInfoAgreementCancelPopupState createState() =>
      _UserInfoAgreementCancelPopupState();
}

class _UserInfoAgreementCancelPopupState
    extends State<UserInfoAgreementCancelPopup> {
  bool isCancel = false;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    double mobileSpan = 16;
    double deskTopSpan = 17;

    void showAlert(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text(
              '개인정보 수집 및 이용 동의 취소',
              style: TextStyle(fontFamily: 'NotoSansKR'),
            ),
            content: SingleChildScrollView(
              // 내용이 길어질 수 있으므로 SingleChildScrollView 사용
              child: ListBody(
                // ListBody를 사용하여 자식들이 수직으로 배치되도록 함
                children: <Widget>[
                  Text(message, style: TextStyle(fontFamily: 'NotoSansKR')),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('확인',
                    style: TextStyle(
                        color: Colors.blue, fontFamily: 'NotoSansKR')),
                onPressed: () {
                  Navigator.of(context).pop(); // 대화상자 닫기
                },
              ),
            ],
          );
        },
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: isMobile ? 358 : 600,
              //height: isMobile ? 373 : 348,
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: isMobile ? 326 : 544,
                        child: buildText(
                            isMobile
                                ? '개인정보 수집 및 이용 동의\n취소 전 확인해주세요'
                                : '개인정보 수집 및 이용 동의 취소 전 확인해주세요',
                            TextType.h4,
                            align: TextAlign.left),
                      ),
                      if (isMobile == false)
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(); // 대화상자 닫기
                            },
                            child: const Icon(Icons.close_rounded, size: 24))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFFDDDDDD),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? mobileSpan : deskTopSpan),
                  SizedBox(
                    child: buildText(
                        isMobile
                            ? '개인정보 수집 및 이용 동의 취소 시,\n배지콕콕 랭킹전 및 경품 이벤트 참여가 제한되며 월간랭킹 선정에서 제외될 수 있습니다.'
                            : '개인정보 수집 및 이용 동의 취소 시, 배지콕콕\n랭킹전 및 경품 이벤트 참여가 제한되며 월간랭킹 선정에서 제외될 수 있습니다.',
                        TextType.p16R,
                        textColor: const Color(0xff333333),
                        align: TextAlign.left),
                  ),
                  SizedBox(height: isMobile ? mobileSpan : deskTopSpan),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    decoration: const BoxDecoration(color: Color(0xFFF1F1F1)),
                    child: buildText(
                        isMobile
                            ? '• 개인정보 수집 및 이용 동의 취소 후, 배지콕콕 페이지에서 랭킹전 및 이벤트 참여 재신청이 가능합니다.'
                            : '• 개인정보 수집 및 이용 동의 취소 후, 배지콕콕 페이지에서 랭킹전 및 이벤트 참여\n   재신청이 가능합니다.',
                        TextType.p14M,
                        align: TextAlign.left),
                  ),
                  SizedBox(height: isMobile ? mobileSpan : deskTopSpan),
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio<bool>(
                          value:
                              true, // 라디오 버튼의 값. 실제 사용시에는 적절한 enum이나 변수로 관리하는 것이 좋습니다.
                          groupValue:
                              isCancel, // 선택된 라디오 버튼의 값을 관리하는 변수. 상태 관리가 필요합니다.
                          onChanged: (bool? value) {
                            setState(() {
                              isCancel = value!;
                            });
                          },
                        ),
                        const Text(
                          '유의사항을 확인했어요.',
                          style: TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 15,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? mobileSpan : deskTopSpan),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 대화상자 닫기
                          },
                          style: const ButtonStyle(
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 11)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(3)), // 모서리를 사각형으로 설정
                              ),
                            ),
                          ),
                          child: buildText('취소', TextType.p16R)),
                      const SizedBox(width: 16),
                      ElevatedButton(
                          onPressed: () async {
                            if (isCancel) {
                              UserPrivacyInfoProvider provider =
                                  Provider.of<UserPrivacyInfoProvider>(context,
                                      listen: false);
                              await provider.updateData(
                                UserPrivacyInfo(
                                  snsQuestInfoId:
                                      provider.userPrivacyInfo.snsQuestInfoId,
                                  isEventAgree: false,
                                  isPrivacyAgree: false,
                                  name: '',
                                  phoneNumber: '',
                                  isExposeRank:
                                      provider.userPrivacyInfo.isExposeRank,
                                  isBadgeTesterMode: provider
                                      .userPrivacyInfo.isBadgeTesterMode,
                                ),
                                () {
                                  Navigator.of(context).pop();
                                  showAlert('랭킹전 참여가 취소되었습니다.');
                                },
                              );
                            } else {
                              Navigator.of(context).pop(); // 대화상자 닫기
                            }
                          },
                          style: const ButtonStyle(
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 11)),
                            backgroundColor:
                                MaterialStatePropertyAll(Color(0xFF001941)),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(3)), // 모서리를 사각형으로 설정
                              ),
                            ),
                          ),
                          child: buildText('확인', TextType.p16R,
                              textColor: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

/// 메인 페이지 유저 배너
class MainBanner extends StatefulWidget {
  MainBanner({
    Key? key,
  }) : super(key: key);

  @override
  _MainBannerState createState() => _MainBannerState();
}

class _MainBannerState extends State<MainBanner> {
  void openRankingPage() async {
    DateTime now = DateTime.now();
    DateTime openDate = DateTime(2024, 4, 29);
    DateTime rankingOpenDate = DateTime(2024, 6, 3);

    try {
      RankingProvider rankingProvider =
          Provider.of<RankingProvider>(context, listen: false);
      await rankingProvider.refreshData('M');

      if (now.isAfter(openDate) && now.isBefore(rankingOpenDate)) {
        buildRankPopup(context);
      } else {
        UserPrivacyInfo privacyInfo = provider.userPrivacyInfo;

        if (privacyInfo.isPrivacyAgree) {
          if (now.isBefore(rankingProvider.groupsInfo.confirmDate)) {
            buildRankPopup(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RankingListPage(),
                  settings:
                      RouteSettings(name: "/questListPage/rankingListPage"),
                ));
          }
        } else {
          showRankAlert('랭킹전을 참여하려면 개인정보수집동의가 필요합니다.', context);
        }
      }
    } catch (e) {
      print('error : $e');
      buildRankPopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    bool isMobile = widthSize < 910;
    return Column(
      children: [
        Container(
            width: 892,
            padding: EdgeInsets.only(
                left: isMobile ? 16 : 0,
                bottom: isMobile ? 16 : 0,
                right: 16,
                top: isMobile ? 16 : 0),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFEDEFFB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 24,
                  offset: Offset(4, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: isMobile
                ? buildMobileBanner(isMobile, widthSize)
                : buildPCBanner(isMobile)),
        Consumer<QuestProvider>(builder: (context, questProvider, child) {
          if (questProvider.isLogin) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: buildText(
                      "※ 획득한 배지는 '배지도감'에서 확인 할 수 있습니다.", TextType.p16R,
                      align: TextAlign.left),
                ),
              ],
            );
          } else {
            return SizedBox();
          }
        })
      ],
    );
  }

  Widget buildMobileBanner(bool isMobile, double screenSize) {
    return Consumer2<QuestProvider, BadgeProvider>(
      builder: (context, questProvider, badgeProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMainBadgeImage(context),
                const SizedBox(width: 6),
                if (questProvider.isLogin)
                  buildUserInfo(isMobile)
                else
                  buildNonLogin(isMobile, screenSize: screenSize),
              ],
            ),
            const SizedBox(height: 16),
            if (questProvider.isLogin) ...[
              buildButtons(isMobile)
            ] else ...[
              buildLoginButton(isMobile)
            ]
          ],
        );
      },
    );
  }

  Widget buildPCBanner(bool isMobile) {
    return Consumer2<QuestProvider, BadgeProvider>(
      builder: (context, questProvider, badgeProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildMainBadgeImage(context),
            const SizedBox(width: 8),
            if (questProvider.isLogin) ...[
              SizedBox(width: 404, child: buildUserInfo(isMobile)),
              const SizedBox(width: 24),
              buildButtons(isMobile)
            ] else ...[
              SizedBox(width: 404, child: buildNonLogin(isMobile)),
              const SizedBox(width: 24),
              buildLoginButton(isMobile)
            ]
          ],
        );
      },
    );
  }

  Widget buildUserInfo(bool isMobile) {
    return SizedBox(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mainBadge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFF4A63AE),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: buildText(
                  '${mainBadge?.badgeinfo.name}',
                  TextType.p14M,
                  textColor: Colors.white,
                ),
              )
            ] else
              buildText(
                '대표배지를 설정해주세요',
                TextType.p14M,
                textColor: const Color(0xFF7D7D7D),
              ),
            const SizedBox(height: 4),
            Consumer<UserInfoProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return buildText('불러오는중..', TextType.p14R);
                }

                return Text(
                  userSession != null
                      ? '${provider.userInfo.snsUserName}님'
                      : '이름이 현재 설정되있지 않습니다.',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'NotoSansKR',
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SizedBox(height: 8), // 간격 조정
            buildStepIconWithPoint(context),
          ]),
    );
  }

  Widget buildNonLogin(bool isMobile, {double screenSize = 0}) {
    return SizedBox(
      //width: isMobile ? 220 : 405,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(
              '아직 획득한 배지가 없어요',
              TextType.h4,
              isAutoSize: isMobile ? true : false,
              screenSize: isMobile ? screenSize : 0,
              textColor: const Color(0xFF222222),
            ),
            const SizedBox(height: 8),
            buildText(
                isMobile
                    ? '로그인 후 도전과제를 수행하여\n배지를 획득해보세요!'
                    : '로그인 후 도전과제를 수행하여 배지를 획득해보세요!',
                TextType.p14R,
                textColor: const Color(0xFF676767),
                align: TextAlign.left,
                isAutoSize: isMobile ? true : false,
                screenSize: isMobile ? screenSize : 0,
                isEllipsis: true),
          ]),
    );
  }

  Widget buildButtons(bool isMobile) {
    if (!isMobile) {
      return SizedBox(
        width: 320,
        height: 86,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                openRankingPage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001940), // 버튼 배경색
                fixedSize: const Size(320, 39),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 0,
              ),
              child: buildText('랭킹보기', TextType.p16M, textColor: Colors.white),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyBadgeCollections(),
                      settings: RouteSettings(
                          name: "/questListPage/myBadgeCollections")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(320, 39),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: buildText('배지도감', TextType.p16M),
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                openRankingPage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001940), // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(8),
                fixedSize: const Size(double.infinity, 39), // 버튼 크기
              ),
              child: buildText('랭킹보기', TextType.p16M,
                  textColor: Colors.white, align: TextAlign.center),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyBadgeCollections(),
                      settings: RouteSettings(
                          name: "/questListPage/myBadgeCollections")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(8),
                fixedSize: const Size(double.infinity, 39), // 버튼 크기
              ),
              child: buildText('배지도감', TextType.p16M, align: TextAlign.center),
            ),
          ),
        ],
      );
    }
  }

  Widget buildLoginButton(bool isMobile) {
    return buildButton(
        '로그인 후 배지 획득하기', Size(isMobile ? double.infinity : 320, 39),
        onPressed: () {
      String url = 'https://$domain/common/login.do'; // 여기에 원하는 웹페이지 주소를 입력하세요.
      redirectToUrl(url);
    });
  }

  // 퀘스트 페이지 대표배지 이미지.
  // mainBadge 데이터 변경시 내용이 변경되야함.
  Widget buildMainBadgeImage(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1000;
    double imageSize = screenWidth * (100 / 390);
    if (imageSize > 120) imageSize = 120;

    return SizedBox(
      width: isMobile ? imageSize : 120,
      height: isMobile ? imageSize : 120,
      child: Consumer2<QuestProvider, BadgeProvider>(
          builder: (context, questProvider, badgeProvider, child) {
        return Image.asset(
          badgeProvider.isSetMainBadge && questProvider.isLogin
              ? 'assets/enable/${mainBadge?.badgeinfo.imgName}.png'
              : 'assets/LockIcon_quest.png',
          fit: BoxFit.fitWidth,
        );
      }),
    );
  }

  // 퀘스트 페이지 대표배지 설정 Card와 랭킹 페이지에 쓰이는 발자국 아이콘과 포인트
  Widget buildStepIconWithPoint(BuildContext context) {
    return Row(
      //mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () async {
            await Provider.of<UserHistoryProvider>(context, listen: false)
                .refreshData('M');
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => MyActivityHistory(),
                  settings:
                      RouteSettings(name: "/questListPage/myActivityHistory")),
            );
          },
          child: Row(
            children: [
              buildText('랭킹점수', TextType.h6),
              buildText('(', TextType.h6),
              Image.asset(
                'assets/Vector_step.png',
                width: 24,
                height: 16,
                fit: BoxFit.fitWidth,
              ),
              buildText(')', TextType.h6),
            ],
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => MyActivityHistory(),
                  settings:
                      RouteSettings(name: "/questListPage/myActivityHistory")),
            );
          },
          child: Consumer<UserInfoProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return buildText('불러오는중..', TextType.p14R);
              }
              return buildText('${provider.userPoint} 보', TextType.h6,
                  align: TextAlign.left);
            },
          ),
        ),
      ],
    );
  }
}

// // 퀘스트 페이지 로그인 했을 때 표시되는 상단 대표 배지 박스 내용.
// // mainBadge 데이터 변경시 내용이 변경되야함.
// Widget buildLoginText(BuildContext context) {
//   return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (mainBadge != null) ...[
//           Container(
//             //width: 89,
//             height: 28,
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: ShapeDecoration(
//               color: const Color(0xFF4A63AE),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5)),
//             ),
//             child: Text(
//               '${mainBadge?.badgeinfo.name}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontFamily: 'NotoSansKR',
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           )
//         ] else
//           const Text(
//             '대표배지를 설정해주세요',
//             style: TextStyle(
//               color: Color(0xFF7D7D7D),
//               fontSize: 12,
//               fontFamily: 'NotoSansKR',
//               fontWeight: FontWeight.w500,
//               height: 1.4, // 줄 높이 조정
//               letterSpacing: -0.24,
//             ),
//           ),
//         const SizedBox(height: 4),
//         Consumer<UserInfoProvider>(
//           builder: (context, provider, child) {
//             if (provider.isLoading) {
//               return const Text('불러오는중..');
//             }
//             return Text(
//               isLogin && userSession != null
//                   ? provider.userInfo.snsUserName
//                   : '이름이 현재 설정되있지 않습니다.',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black,
//                 fontFamily: 'NotoSansKR',
//                 fontWeight: FontWeight.w700,
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 10), // 간격 조정
//         buildStepIconWithPoint(context),
//       ]);
// }
