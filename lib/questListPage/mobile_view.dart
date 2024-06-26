import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitkorea/model/quest.dart';
//import 'package:visitkorea/model/userSession.dart';
//import 'package:visitkorea/rankingListpage/rankingListPage.dart';
import '../common_widgets.dart';
import 'questListPage.dart';
import '../jsonLoader.dart';

String initValue = '${DateTime.now().year.toString()}년';

class MobileLayout_questList extends StatefulWidget {
  MobileLayout_questList({
    Key? key,
  }) : super(key: key);

  @override
  _MobileLayoutState_questList createState() => _MobileLayoutState_questList();
}

class _MobileLayoutState_questList extends State<MobileLayout_questList> {
  @override
  Widget build(BuildContext context) {
    return buildMobileLayout(context);
  }

  Widget buildMobileLayout(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double badgeSectionSpacing = 40;

    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        buildTitleBannerImg_mobile(context),
        const SizedBox(height: 16),
        Center(
            child: SizedBox(
                width: screenWidth - 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MainBanner(),
                    SizedBox(height: 40),
                    buildBadgeSection(context, QuestType.event, true),
                    Consumer3<UserPrivacyInfoProvider, QuestProvider,
                        EventBannerProvider>(
                      builder: (context, priprovider, questProvider,
                          eventBannerProvider, child) {
                        if (questProvider.isLoading) {
                          return SizedBox(height: badgeSectionSpacing);
                        }

                        if (questProvider.isLogin == false) {
                          return SizedBox(height: badgeSectionSpacing);
                        }

                        print('이벤트 배너 노출 시작');
                        if (priprovider.isLoading ||
                            eventBannerProvider.isLoading) {
                          return SizedBox(height: badgeSectionSpacing);
                        }

                        if (questProvider.isLogin &&
                            eventBannerProvider.bannerInfo.commonBanner) {
                          if (priprovider.userPrivacyInfo.isPrivacyAgree ==
                              false) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildEventBaaner(true, context, screenWidth),
                                SizedBox(height: 40),
                              ],
                            );
                          } else {
                            return SizedBox(height: badgeSectionSpacing);
                          }
                        } else {
                          return SizedBox(height: badgeSectionSpacing);
                        }
                      },
                    ), // Event 타입 배지가 있으면 카드 추가
                    buildBadgeSection(context, QuestType.activity, true),
                    SizedBox(height: badgeSectionSpacing),
                    buildBadgeSection(context, QuestType.exploer, false),
                  ],
                ))),
        buildNoticeSection_Mobile(),
      ],
    );
  }

  Widget buildBadgeSection(
      BuildContext context, QuestType type, bool isDropDownButton) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비를 가져옵니다.
    double padding = 16 * (screenWidth / 390); // 좌우 패딩
    double availableWidth = screenWidth - padding * 2;

    double itemWidth = 109 * (availableWidth / 390);
    if (itemWidth > 109) itemWidth = 109;
    double itemHeight = 134 * (availableWidth / 390);
    if (itemHeight > 134)
      itemHeight = 134;
    else if (itemHeight < 100) itemHeight = 100;

    //print('ItemSize : $itemWidth , $itemHeight');

    double imageSize = 84 * (availableWidth / 390);
    if (imageSize > 84) imageSize = 84;

    List<Quest> setDuringQuestList(String dropDownValue, List<Quest> quests) {
      List<Quest> filterdQuests = quests.toList();
      for (var quest in quests) {
        DateTime startDate =
            DateTime.parse(quest.questDetails.activationStartDate);
        DateTime endDate = DateTime.parse(quest.questDetails.activationEndDate);
        // 상시 노출 퀘스트는 무조건 노출
        if (endDate.year != 2999) {
          if (dropDownValue == '2024년') {
            if (startDate.isAfter(DateTime(2024)) ||
                endDate.isBefore(DateTime(2024))) {
              filterdQuests.remove(quest);
            }
          } else if (dropDownValue == '2025년') {
            if (startDate.isAfter(DateTime(2025)) ||
                endDate.isBefore(DateTime(2025))) {
              filterdQuests.remove(quest);
            }
          }
        } else {
          if (dropDownValue == '2024년') {
            if (startDate.isAfter(DateTime(2024))) {
              filterdQuests.remove(quest);
            }
          } else if (dropDownValue == '2025년') {
            if (startDate.isAfter(DateTime(2025))) {
              filterdQuests.remove(quest);
            }
          }
        }
      }

      return filterdQuests;
    }

    return Consumer3<QuestProvider, BadgeProvider, UserPrivacyInfoProvider>(
      builder: (context, questProvider, badgeProvider, userPrivacyInfoProvider,
          child) {
        if (questProvider.isLoading ||
            badgeProvider.isLoading ||
            userPrivacyInfoProvider.isLoading) {
          return SizedBox();
        }

        // 퀘스트 타입에 맞게 리스트 불러오기
        List<Quest> quests = filterQuests(
            questProvider.questList
                .where((quest) => quest.questDetails.questType == type)
                .toList(),
            badgeProvider.badgeList);

        String title = getQuestSectionTitleByType(type);

        bool isVIP = false;

        for (var quest in quests) {
          // VIP 배지를 보유중인지 체크
          // 배지수령중인 상태를 체크하려면 isCompleted가 false인 상태에서 완료됐는지 체크가 되야하는데
          // Action Count(달성조건)가 0이기 때문에 체크 할 방법이 현재는 없음. 수령 안한 상태를 적용 할 수가 없음.
          if (quest.questDetails.groupIndex == 38) {
            if (quest.progressType.index > 1) {
              isVIP = true;
            }
          }

          // ExposeStatus 값에 따라 배지 리스트에서 배지 삭제
          if (quest.questDetails.exposeStatus == ExposeStatus.waiting) {
            badgeProvider.badgeList.removeWhere((badge) =>
                quest.questDetails.enableBadge?.badgeId ==
                badge.badgeinfo.badgeId);
          } else if (quest.questDetails.exposeStatus == ExposeStatus.testing) {
            if (questProvider.isLogin &&
                !userPrivacyInfoProvider.userPrivacyInfo.isBadgeTesterMode) {
              badgeProvider.badgeList.removeWhere((badge) =>
                  quest.questDetails.enableBadge?.badgeId ==
                  badge.badgeinfo.badgeId);
            }
          }

          if (title != '전국탐방') {
            DateTime startDate =
                DateTime.parse(quest.questDetails.activationStartDate);
            DateTime endDate =
                DateTime.parse(quest.questDetails.activationEndDate);
            // 퀘스트 활성화 년도가 25년도가 있으면 추가
            if ((startDate.isAfter(DateTime(2024))) &&
                !dropDownValuelist[title]!.contains('2025년')) {
              if (endDate.year != 2999) {
                dropDownValuelist[title]!.add('2025년');
              }
            }
          }
        }
        List<Quest> vipBadges = quests
            .where((quest) => quest.questDetails.groupIndex == 38)
            .toList();

        if (isVIP == false) {
          for (var vip in vipBadges) {
            if (vip.questDetails.name != '콕콕학사') {
              quests.remove(quests.where((quest) => quest == vip).single);
            }
          }
        } else {
          for (var vip in vipBadges) {
            if (vip.progressType.index < 2) {
              quests.remove(quests.where((quest) => quest == vip).single);
            }
          }
        }

        // 테스터 모드가 아닌 사용자는 테스트 상태인 퀘스트 삭제.
        if (questProvider.isLogin) {
          if (!userPrivacyInfoProvider.userPrivacyInfo.isBadgeTesterMode) {
            quests.removeWhere((quest) =>
                quest.questDetails.exposeStatus == ExposeStatus.testing);
          }
        }

        // 대기중인 퀘스트는 삭제
        quests.removeWhere(
            (quest) => quest.questDetails.exposeStatus == ExposeStatus.waiting);
        quests = setDuringQuestList(
            dropDownValueQuestType[title].toString(), quests);
        if (quests.isEmpty) return const SizedBox();
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText(title, TextType.h4),
                if (isDropDownButton)
                  CustomDropdownMenu(
                    menuItems: dropDownValuelist[title]!,
                    initialValue: dropDownValueQuestType[title].toString(),
                    isEnable: true,
                    onItemSelected: (String selectedValue) {
                      dropDownValueQuestType[title] = selectedValue;
                      questProvider.refreshQuests();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
                clipBehavior: Clip.antiAlias,
                decoration: buildShadowDecoration(),
                padding: EdgeInsets.all(padding),
                child: buildGrid(
                    quests, itemWidth, itemHeight, padding, screenWidth,
                    imageSize: imageSize)),
            // 임시 기능으로 전국탐방 섹션에 계정 초기화 버튼 삽입.
            if (title == '전국탐방' && questProvider.isLogin) ...[
              Consumer2<UserPrivacyInfoProvider, EventBannerProvider>(
                  builder: (context, priProvider, eventBannerProvider, child) {
                if (priProvider.isLoading || eventBannerProvider.isLoading) {
                  return SizedBox(height: 16);
                }
                if (eventBannerProvider.bannerInfo.commonBanner) {
                  if (priProvider.userPrivacyInfo.isPrivacyAgree) {
                    print('개인정보 동의 상태임 취소 배너 생성');
                    return Column(
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: buildPrivacyCancelCard(true, context),
                        ),
                        const SizedBox(height: 13),
                      ],
                    );
                  } else {
                    return const SizedBox(height: 16);
                  }
                } else {
                  return const SizedBox(height: 16);
                }
              })
            ]
          ],
        );
      },
    );
  }
}

Widget buildGrid(List<Quest> quest, double pWidth, double pHeight,
    double padding, double screenSzie,
    {double imageSize = 90}) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 24 * (screenSzie / 390),
      childAspectRatio: pWidth / pHeight,
    ),
    itemCount: quest.length,
    itemBuilder: (BuildContext context, int index) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getQuestImageByProgressType(context, quest[index],
              imageWidth: imageSize, imageHeight: imageSize),
          SizedBox(height: 12 * (screenSzie / 390)),
          // 퀘스트 이름 표시.
          // VIP 퀘스트면(orderIndex == 20) conditionName을 표시
          buildText(
              quest[index].questDetails.groupIndex == 38
                  ? quest[index].completed
                      ? quest[index].questDetails.name
                      : quest[index].questDetails.conditionName
                  : quest[index].questDetails.name,
              TextType.p14M,
              screenSize: screenSzie,
              isAutoSize: true,
              isEllipsis: true),
          if (quest[index].questDetails.nextQuestId != null)
            buildText(quest[index].questDetails.grade, TextType.p14B,
                screenSize: screenSzie,
                isAutoSize: true,
                textColor: const Color(0xff5869FF)),
          if (quest[index].questDetails.questType.name == 'event')
            buildText(
                '${quest[index].questDetails.activationStartDate.substring(5, 10)}~${quest[index].questDetails.activationEndDate.substring(5, 10)}',
                TextType.p14M,
                screenSize: screenSzie,
                isAutoSize: true,
                textColor: const Color(0xff5869FF))
        ],
      );
    },
  );
}
