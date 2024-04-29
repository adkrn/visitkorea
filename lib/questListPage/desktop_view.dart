import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitkorea/model/quest.dart';
//import 'package:visitkorea/model/userSession.dart';
//import 'package:visitkorea/rankingListpage/rankingListPage.dart';
import '../common_widgets.dart';
import 'questListPage.dart';
import '../jsonLoader.dart';

class DesktopLayout_questList extends StatefulWidget {
  DesktopLayout_questList({
    Key? key,
  }) : super(key: key);

  @override
  _DesktopLayoutState_questList createState() =>
      _DesktopLayoutState_questList();
}

class _DesktopLayoutState_questList extends State<DesktopLayout_questList> {
  double widthSize = 940;
  double badgeSectionSpacing = 40;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        //buildTitleBanner(),
        buildTitleBannerImg(context),
        Center(
          child: Container(
            width: widthSize,
            padding: const EdgeInsets.all(24),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainBanner(),
                SizedBox(height: badgeSectionSpacing),
                buildBadgeSection(context, QuestType.event, true),
                Consumer3<UserPrivacyInfoProvider, QuestProvider,
                    EventBannerProvider>(
                  builder: (context, priprovider, questProvider,
                      eventBannerProvider, child) {
                    if (priprovider.isLoading ||
                        questProvider.isLoading ||
                        eventBannerProvider.isLoading) {
                      return SizedBox(height: badgeSectionSpacing);
                    }

                    if (questProvider.isLogin &&
                        eventBannerProvider.bannerInfo.commonBanner) {
                      if (priprovider.userPrivacyInfo.isPrivacyAgree == false) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildEventBaaner(false, context, widthSize),
                            SizedBox(height: badgeSectionSpacing),
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
            ),
          ),
        ),
        buildNoticeSection_Desktop(),
      ],
    );
  }

  Widget buildBadgeSection(
      BuildContext context, QuestType type, bool isDropDownButton) {
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
          // 어느 하나라도 데이터 로딩 중이면 로딩 인디케이터 표시
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
        bool isVIPTest = false;
        for (var quest in quests) {
          // VIP 배지를 보유중인지 체크
          // 배지수령중인 상태를 체크하려면 isCompleted가 false인 상태에서 완료됐는지 체크가 되야하는데
          // Action Count(달성조건)가 0이기 때문에 체크 할 방법이 현재는 없음. 수령 안한 상태를 적용 할 수가 없음.
          if (quest.questDetails.conditionName == '대구석VIP 달성하기') {
            if (quest.progressType.index > 1) {
              isVIP = true;
            }
            if (quest.questDetails.exposeStatus.index < 2) {
              isVIPTest = true;
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
            .where((quest) => quest.questDetails.conditionName == '대구석VIP 달성하기')
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

        // vip 3개중에 하나라도 오픈중이 아니면 전부 비노출
        if (isVIPTest == true) {
          for (var vip in vipBadges) {
            quests.removeWhere((quest) => quest == vip);
          }
        }

        // 테스터 모드가 아닌 사용자는 테스트 상태인 퀘스트 삭제.
        if (questProvider.isLogin) {
          if (!userPrivacyInfoProvider.userPrivacyInfo.isBadgeTesterMode &&
              questProvider.isLogin) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText(title, TextType.h2),
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
                decoration: buildShadowDecoration(),
                padding: const EdgeInsets.all(24),
                child: buildGrid(context, quests)),
            // 임시 기능으로 전국탐방 섹션에 계정 초기화 버튼 삽입.
            if (title == '전국탐방' && questProvider.isLogin) ...[
              Consumer2<UserPrivacyInfoProvider, EventBannerProvider>(
                  builder: (context, priProvider, eventBannerProvider, child) {
                if (priProvider.isLoading || eventBannerProvider.isLoading) {
                  return SizedBox();
                }
                if (eventBannerProvider.bannerInfo.commonBanner) {
                  if (priProvider.userPrivacyInfo.isPrivacyAgree) {
                    return Column(
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: buildPrivacyCancelCard(true, context),
                        )
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                } else {
                  return const SizedBox();
                }
              })
            ],
          ],
        );
      },
    );
  }

  Widget buildGrid(BuildContext context, List<Quest> quest) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 40,
        mainAxisSpacing: 10,
        childAspectRatio: 1 / 1.3, // 아이템의 가로세로 비율을 조정하여 더 높은 아이템 생성
      ),
      itemCount: quest.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getQuestImageByProgressType(context, quest[index]),
            const SizedBox(height: 12),
            buildText(
                quest[index].questDetails.orderIndex == 20
                    ? quest[index].completed
                        ? quest[index].questDetails.name
                        : quest[index].questDetails.conditionName
                    : quest[index].questDetails.name,
                TextType.p16M,
                isEllipsis: true),
            if (quest[index].questDetails.nextQuestId != null)
              buildText(quest[index].questDetails.grade, TextType.h6,
                  textColor: const Color(0xff5869FF)),
            if (quest[index].questDetails.questType.name == 'event')
              buildText(
                  '${quest[index].questDetails.activationStartDate.substring(5, 10)}~${quest[index].questDetails.activationEndDate.substring(5, 10)}',
                  TextType.p16M,
                  textColor: const Color(0xff5869FF),
                  isEllipsis: true)
          ],
        );
      },
    );
  }
}
