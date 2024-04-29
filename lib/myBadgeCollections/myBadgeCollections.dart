import 'package:flutter/material.dart';
import '../common_widgets.dart';
import 'desktop_view.dart';
import 'mobile_view.dart';
import '../model/quest.dart';

// 팝업메뉴 값
Map<String, String> badgeDropdownValues = {
  '이벤트': '2024년',
  '일반활동': '2024년',
};

List<String> dropdownValuelist = <String>['2024년'];

Map<String, List<String>> badgeDropdownValuelist = {
  '이벤트': dropdownValuelist,
  '일반활동': dropdownValuelist
};

String getBadgeSectionTitleByType(QuestType type) {
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

class MyBadgeCollections extends StatefulWidget {
  @override
  _MyBadgeCollectionsState createState() => _MyBadgeCollectionsState();
}

bool isLoad = false;

class _MyBadgeCollectionsState extends State<MyBadgeCollections> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Scaffold(
      appBar: CustomAppBar(appBarHeight: isMobile ? 98 : 90),
      body: isMobile
          ? MobileLayout_myBadgeCollections()
          : DesktopLayout_myBadgeCollections(),
    );
  }
}

// 배지도감에서 쓰이는 보유한 배지가 없을때 표시하는 빈 박스
Widget buildEmptyBox(double pHeight) {
  return Container(
    width: double.infinity,
    height: pHeight,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: buildText(
              '시작이 반이에요.\n도전과제에 참여하여 다양한 배지를 수집해보세요!', TextType.p16R,
              textColor: const Color(0xFF999999)),
        ),
      ],
    ),
  );
}
