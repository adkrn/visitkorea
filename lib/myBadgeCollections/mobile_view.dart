import 'package:flutter/material.dart';
import '../common_widgets.dart';
import '../model/quest.dart';
import '../popup/badgeInfoPopup.dart';
import 'myBadgeCollections.dart';
import 'package:provider/provider.dart';
import '../jsonLoader.dart';

class MobileLayout_myBadgeCollections extends StatefulWidget {
  // final List<Badge_completed> exploreKoreanBadge;
  // final List<Badge_completed> eventBadge;

  MobileLayout_myBadgeCollections({
    Key? key,
    //required this.exploreKoreanBadge,
    //required this.eventBadge
  }) : super(key: key);

  @override
  _MobileLayoutState_myBadgeCollections createState() =>
      _MobileLayoutState_myBadgeCollections();
}

class _MobileLayoutState_myBadgeCollections
    extends State<MobileLayout_myBadgeCollections> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Center(
          child: SizedBox(
            width: 640,
            child: Column(
              children: [
                buildRepresentativebadgesCard(true),
                const SizedBox(height: 16),
                buildBadgeSection(context, QuestType.event, true),
                const SizedBox(height: 16),
                buildBadgeSection(context, QuestType.activity, true),
                const SizedBox(height: 16),
                buildBadgeSection(context, QuestType.exploer, true),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      buildNoticeSection_Mobile(),
    ]);
  }

  Widget buildBadgeSection(
      BuildContext context, QuestType type, bool isDropDownButton) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비를 가져옵니다.
    double padding = 16 * (screenWidth / 390); // 좌우 패딩
    double availableWidth = screenWidth - padding * 2;

    double itemWidth = 109 * (availableWidth / 390);
    if (itemWidth > 109) itemWidth = 109;
    double itemHeight = 134 * (availableWidth / 390);
    if (itemHeight > 134) {
      itemHeight = 134;
    }

    //print('ItemSize : $itemWidth , $itemHeight');

    double imageSize = 84 * (availableWidth / 390);
    if (imageSize > 100) imageSize = 100;

    //print('imageSize : $imageSize');
    return Consumer<BadgeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          // 어느 하나라도 데이터 로딩 중이면 로딩 인디케이터 표시
          return Center(child: CircularProgressIndicator());
        }
        // 배지 타입에 맞게 리스트 불러오기
        List<Badge_completed> badges = provider.badgeList
            .where((e) => e.badgeinfo.badgeType == type)
            .toList();
        // 보유한 배지가 있는지 확인.
        bool hasBadge = badges.any((element) => badges != []);

        if (type == QuestType.event && hasBadge == false) {
          return SizedBox();
        }

        String title = getBadgeSectionTitleByType(type);

        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildText(title, TextType.h4),
                  if (isDropDownButton)
                    CustomDropdownMenu(
                      menuItems: badgeDropdownValuelist,
                      initialValue: '2024년',
                      isEnable: true,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                  padding: EdgeInsets.only(right: padding, left: padding),
                  decoration: BoxDecoration(
                    // 하단에만 테두리 선을 추가
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFEEEEEE), // 선의 색상 설정
                        width: 1.0, // 선의 두께 설정
                      ),
                    ),
                  ),
                  child: hasBadge
                      ? buildGrid(badges, itemWidth, itemHeight, screenWidth,
                          imageSize: itemWidth)
                      : buildEmptyBox(115)),
            ]);
      },
    );
  }

  Widget buildGrid(List<Badge_completed> badges, double pWidth, double pHeight,
      double screenSzie,
      {double imageSize = 90}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 24 * (screenSzie / 390),
        childAspectRatio: pWidth / pHeight,
      ),
      itemCount: badges.length,
      itemBuilder: (BuildContext context, int index) {
        return buildItem(context, badges[index],
            imageSize: imageSize, screenSize: screenSzie);
      },
    );
  }

  Widget buildItem(BuildContext context, Badge_completed badge,
      {double imageSize = 90, screenSize = 0}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => showBadgePopup(context, badge),
          child: Image.asset(
            'assets/enable/${badge.badgeinfo.imgName}.png',
            width: imageSize,
            height: imageSize,
            fit: BoxFit.fitWidth,
          ),
        ),
        buildText(badge.badgeinfo.name, TextType.p14M,
            isEllipsis: true, isAutoSize: true, screenSize: screenSize),
      ],
    );
  }
}
