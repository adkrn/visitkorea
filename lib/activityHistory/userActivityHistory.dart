import 'package:flutter/material.dart';
import 'package:visitkorea/jsonLoader.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../common_widgets.dart';

// 나의 활동 내역 페이지
class MyActivityHistory extends StatefulWidget {
  @override
  _MyActivityHistoryState createState() => _MyActivityHistoryState();
}

class _MyActivityHistoryState extends State<MyActivityHistory> {
  @override
  Widget build(BuildContext context) {
    print('build');
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Scaffold(
      appBar: CustomAppBar(appBarHeight: isMobile ? 98 : 90),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: isMobile ? double.infinity : 940,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      child: Row(
                    children: [
                      Image.asset('assets/Vector_step.png'),
                      const SizedBox(width: 4),
                      buildText('활동내역', isMobile ? TextType.h4 : TextType.h3),
                    ],
                  )),
                  SizedBox(
                    child: buildText(
                        '회원코드:${Provider.of<UserInfoProvider>(context, listen: false).userInfo.indexId}',
                        TextType.h6),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: isMobile ? double.infinity : 940,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomDropdownMenu(
                    menuItems: ['월간', '연간'],
                    initialValue: '월간',
                    isEnable: true,
                    onItemSelected: (String selectedValue) {
                      Provider.of<UserHistoryProvider>(context, listen: false)
                          .refreshData(selectedValue == '월간' ? 'M' : 'Y');
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(child: buildTable(context, isMobile)),
        ],
      ),
    );
  }

  Widget buildTable(BuildContext context, bool isMobile) {
    double desckTopWidthSize = 302.67;
    return Consumer<UserHistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SizedBox();
        }

        // 리스트가 적을경우 푸터사이의 여백을 주기위한 높이값.
        int historyCount = provider.historyList.length;
        double boxHeight = 640 - (historyCount * 80);
        if (boxHeight < 0) boxHeight = 0;

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  width: isMobile ? double.infinity : 940,
                  height: 40,
                  decoration: const BoxDecoration(
                      border: Border(
                    top: BorderSide(width: 1, color: Color(0xFF222222)),
                    bottom: BorderSide(color: Color(0xFFEAEAEA)),
                  )),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: isMobile ? 150 : desckTopWidthSize,
                          child: buildText('구분', TextType.h6,
                              align: isMobile
                                  ? TextAlign.left
                                  : TextAlign.center)),
                      SizedBox(
                        width: isMobile ? 104 : desckTopWidthSize,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildText('랭킹 점수', TextType.h6),
                            const SizedBox(width: 4),
                            Image.asset('assets/icon_footprint.png'),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: isMobile ? 104 : desckTopWidthSize,
                          child: Center(child: buildText('획득일시', TextType.h6))),
                    ],
                  ),
                ),
              ),
            ),
            if (provider.historyList.isEmpty) ...[
              SizedBox(
                  width: isMobile ? 390 : 940,
                  height: 500,
                  child: const Center(
                      child: Text(
                    '활동 내역이 없습니다.',
                    style: TextStyle(fontFamily: 'NotoSansKR'),
                  ))),
              buildNoticeSection_Mobile(),
            ] else
              // DataRow 스크롤 가능
              Expanded(
                child: ListView.builder(
                  // 푸터와 여백을 리스트뷰 하단에 배치하기위해 count를 1더해줌.
                  itemCount: historyCount + 1,
                  itemBuilder: (context, index) {
                    final history = index < provider.historyList.length
                        ? provider.historyList[index]
                        : null;
                    if (history != null) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: isMobile ? double.infinity : 940,
                          height: 80,
                          decoration: const BoxDecoration(
                              border: Border(
                            bottom: BorderSide(color: Color(0xFFEAEAEA)),
                          )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: isMobile ? 150 : desckTopWidthSize,
                                  child: buildText(
                                      history.questName, TextType.p16M,
                                      align: isMobile
                                          ? TextAlign.left
                                          : TextAlign.center)),
                              Container(
                                width: isMobile ? 104 : desckTopWidthSize,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: buildText(
                                  history.point.contains('-')
                                      ? history.point
                                      : '+${history.point}',
                                  isMobile ? TextType.p14B : TextType.h6,
                                  textColor: history.point.contains('-')
                                      ? const Color(0xFFD70000)
                                      : const Color(0xFF00A123),
                                ),
                              ),
                              Container(
                                width: isMobile ? 104 : desckTopWidthSize,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: buildText(
                                      DateFormat(isMobile
                                              ? 'yyyy-MM-dd\n  HH:mm:ss'
                                              : 'yyyy-MM-dd HH:mm:ss')
                                          .format(history.createDateTimeStamp),
                                      TextType.p14R),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                    } else {
                      return Column(
                        // 여백, 푸터영역 표시.
                        children: [
                          SizedBox(height: boxHeight),
                          buildNoticeSection_Desktop(),
                        ],
                      );
                    }
                  },
                ),
              )
          ],
        );
      },
    );
  }
}
