import 'package:flutter/material.dart';
import '../common_widgets.dart';
import '../model/quest.dart';
import '../popup/badgeInfoPopup.dart';
import 'myBadgeCollections.dart';
import 'package:provider/provider.dart';
import '../jsonLoader.dart';

class DesktopLayout_myBadgeCollections extends StatefulWidget {
  // final List<Badge_complted> exploreKoreanBadge;
  // final List<Badge_complted> eventBadge;

  DesktopLayout_myBadgeCollections({
    Key? key,
    //required this.exploreKoreanBadge,
    //required this.eventBadge
  }) : super(key: key);
  @override
  _DesktopLayoutState_myBadgeCollections createState() =>
      _DesktopLayoutState_myBadgeCollections();
}

class _DesktopLayoutState_myBadgeCollections
    extends State<DesktopLayout_myBadgeCollections> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Center(
        child: Container(
          width: 940,
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              buildRepresentativebadgesCard(false),
              const SizedBox(height: 16),
              buildBadgeSection(context, QuestType.event, true),
              const SizedBox(height: 16),
              buildBadgeSection(context, QuestType.activity, true),
              const SizedBox(height: 16),
              buildBadgeSection(context, QuestType.exploer, true),
            ],
          ),
        ),
      ),
      buildNoticeSection_Desktop(),
    ]);
  }

  Widget buildBadgeSection(
    BuildContext context,
    QuestType type,
    bool isDropDownButton,
  ) {
    return Consumer<BadgeProvider>(builder: (context, provider, child) {
      if (provider.isLoading) {
        // 어느 하나라도 데이터 로딩 중이면 로딩 인디케이터 표시
        return const Center(child: CircularProgressIndicator());
      }
      List<Badge_completed> badges = provider.badgeList
          .where((e) => e.badgeinfo.badgeType == type)
          .toList();
      // 보유한 배지가 있는지 확인.
      bool hasBadge = badges.any((element) => badges != []);
      if (type == QuestType.event && hasBadge == false) {
        return SizedBox();
      }

      String title = getBadgeSectionTitleByType(type);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText(title, TextType.h3),
              if (isDropDownButton)
                CustomDropdownMenu(
                  menuItems: badgeDropdownValuelist,
                  initialValue: '2024년',
                  isEnable: true,
                ),
            ],
          ),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                // 하단에만 테두리 선을 추가
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFEEEEEE), // 선의 색상 설정
                    width: 1.0, // 선의 두께 설정
                  ),
                ),
              ),
              child:
                  hasBadge ? buildGrid(context, badges) : buildEmptyBox(140)),
        ]),
      );
    });
  }

  Widget buildGrid(BuildContext context, List<Badge_completed> badges) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 40,
        mainAxisSpacing: 24,
        childAspectRatio: 1 / 1.2,
      ),
      itemCount: badges.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            buildItem(context, badges[index]),
            const SizedBox(height: 12),
            buildText(badges[index].badgeinfo.name, TextType.p16M,
                isEllipsis: true),
          ],
        );
      },
    );
  }

  Widget buildItem(BuildContext context, Badge_completed badge) {
    return Container(
      //width: 90,
      //height: 100,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => showBadgePopup(context, badge),
            child: Container(
              width: 126,
              height: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/enable/${badge.badgeinfo.imgName}.png"),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
