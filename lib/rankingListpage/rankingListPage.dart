import 'package:provider/provider.dart';
import 'package:visitkorea/jsonLoader.dart';

import '../common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:visitkorea/rankingListpage/mobile_view.dart';
import 'package:visitkorea/rankingListpage/desktop_view.dart';
import 'package:visitkorea/model/userRankingInfo.dart';
import '../main.dart';

class RankingListPage extends StatefulWidget {
  @override
  _RankingListPageState createState() => _RankingListPageState();
}

class _RankingListPageState extends State<RankingListPage> {
  late RankingProvider provider;
  bool _isProviderInitialized = false;
  bool _isShowPopup = false;

  @override
  void didChangeDependencies() {
    print('didChangeDependencies Start');
    super.didChangeDependencies();
    if (!_isProviderInitialized) {
      provider = Provider.of<RankingProvider>(context, listen: false);
    }
    print('didChangeDependencies End');
  }

  @override
  void initState() {
    print('initState Start');
    super.initState();

    Future.microtask(() async {
      await provider.refreshData('M');

      setState(() {
        _isProviderInitialized = true;
        _showDialog(context);
      });
    });
  }

  void _showDialog(BuildContext context) {
    print('showDialogStart');
    if (_isShowPopup) return;

    _isShowPopup = true;
    UserRankingInfo? thisUser = provider.getThisUser(userSession!.snsId);

    showDialog(
      context: context,
      builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Consumer<RankingProvider>(
            builder: (context, value, child) {
              if (value.isLoading) {
                return SizedBox();
              }

              // 사용자가 없거나 랭크가 100보다 큰 경우와 그렇지 않은 경우를 구분
              Widget dialogChild;

              if (provider.groupsInfo.popupYn == false) {
                dialogChild = SizedBox();
                Navigator.pop(context);
              } else {
                if (thisUser == null) {
                  dialogChild = showNotRankedPopup(context);
                } else {
                  if (thisUser.ranking > 100) {
                    dialogChild = showRankingNotEnteredPopup(context);
                  } else {
                    dialogChild = showRankingToolTipPopup(context);
                  }
                }
              }
              return dialogChild;
            },
          )),
    );
    print('showDialogEnd');
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 910;
    return Scaffold(
      appBar: CustomAppBar(appBarHeight: isMobile ? 98 : 90),
      body: _isProviderInitialized == true
          ? loadLayout(context, isMobile)
          : Center(
              child: Column(children: [
                SizedBox(height: 300),
                CircularProgressIndicator(),
                SizedBox(height: 300),
              ]),
            ),
    );
  }

  StatefulWidget loadLayout(BuildContext context, bool isMobile) {
    if (isMobile) {
      return MobileLayout_rankingList();
    } else {
      return DesktopLayout_rankingList();
    }
  }
}

Widget showRankingToolTipPopup(BuildContext context) {
  var provider = Provider.of<RankingProvider>(context, listen: false);
  return Container(
    width: 358,
    padding: const EdgeInsets.all(16),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                child: buildText('축하합니다!', TextType.h4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: buildText('월간 랭킹 100위 내에 진입하였습니다!', TextType.p16R),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: const Color(0xFFEDEFFB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildText('지난달 나의 랭킹', TextType.p18R),
              const SizedBox(width: 10),
              Image.asset('assets/popupTextLine.png'),
              const SizedBox(width: 10),
              buildText('${provider.getThisUser(userSession!.snsId)?.ranking}위',
                  TextType.h5),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xEEEEEEEE),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF001941)),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: buildText('확인', TextType.p16M, textColor: Colors.white),
          ),
        )
      ],
    ),
  );
}

Widget showNotRankedPopup(BuildContext context) {
  var point = Provider.of<UserInfoProvider>(context, listen: false).userPoint;
  return Container(
    width: 358,
    padding: const EdgeInsets.all(16),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                child: buildText('지난달 랭킹 발표', TextType.h4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: buildText('이번달에는 랭킹전 순위권에 도전해보세요!', TextType.p14M),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: const Color(0xFFEDEFFB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildText('지난달 나의 랭킹 점수', TextType.p14B),
              Image.asset(width: 20, 'assets/Vector_step.png'),
              const SizedBox(width: 10),
              buildText('$point', TextType.p14B),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xEEEEEEEE),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF001941)),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: buildText('확인', TextType.p16M, textColor: Colors.white),
          ),
        )
      ],
    ),
  );
}

Widget showRankingNotEnteredPopup(BuildContext context) {
  var rankProvider = Provider.of<RankingProvider>(context, listen: false);
  var point = Provider.of<UserInfoProvider>(context, listen: false).userPoint;
  double screenSize = MediaQuery.of(context).size.width;
  bool isMobile = screenSize < 910;
  return Container(
    width: isMobile ? 358 : 450,
    padding: EdgeInsets.all(isMobile ? 16 * (358 / screenSize) : 16),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildText('지난달 랭킹 발표', TextType.h4),
        const SizedBox(height: 4),
        buildText('이번달에는 랭킹전 순위권에 도전해보세요!', TextType.p16R),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 * (326 / screenSize) : 16,
              vertical: isMobile ? 8 * (326 / screenSize) : 8),
          decoration: ShapeDecoration(
            color: const Color(0xFFEDEFFB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: buildText(
                        screenSize < 390 ? '지난달 나의\n랭킹 점수' : '지난달 나의 랭킹 점수',
                        TextType.p18R,
                        isAutoSize: true,
                        screenSize: 326,
                        align: TextAlign.left),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/Vector_step.png',
                          width: 24, height: 24),
                      SizedBox(width: 4),
                      buildText('$point', TextType.h5,
                          isAutoSize: true, screenSize: 326),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: buildText(
                        screenSize < 390
                            ? '지난달 100위의\n랭킹 점수'
                            : '지난달 100위의 랭킹 점수',
                        TextType.p18R,
                        isAutoSize: true,
                        screenSize: 326,
                        align: TextAlign.left),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/Vector_step.png',
                          width: 24, height: 24),
                      SizedBox(width: 4),
                      buildText(
                          '${rankProvider.userList.last.point}', TextType.h5,
                          isAutoSize: true, screenSize: 326),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xEEEEEEEE),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: isMobile ? double.infinity : 150,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Color(0xFF001941)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
              //fixedSize: MaterialStatePropertyAll(Size.fromWidth(isMobile ? double.infinity : 150))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
  );
}

Widget buildRankNoticeSection() {
  Color textColor = const Color(0xFF7D7D7D);
  return Container(
    color: const Color(0xfff7f7f7),
    child: Center(
      child: Container(
        width: 940,
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText('랭킹전 수행 유의사항', TextType.h5),
            const SizedBox(height: 16),
            buildText('• 랭킹전은 개인정보 수집 및 이용 동의자만 참여 가능합니다.', TextType.p14R,
                textColor: textColor, align: TextAlign.left),
            const SizedBox(height: 8),
            buildText('• 랭킹점수는 대한민국 구석구석 내 활동내역을 바탕으로 지급됩니다.', TextType.p14R,
                textColor: textColor, align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 불법적이거나 정상적이지 않은 방법으로 도전과제를 수행한 경우, 랭킹점수가 모두 회수될 수 있습니다.',
                TextType.p14R,
                textColor: textColor,
                align: TextAlign.left),
            const SizedBox(height: 8),
            buildText('• 랭킹전은 월간/연간 랭킹으로 구분 운영됩니다.', TextType.p14R,
                textColor: textColor, align: TextAlign.left),
            const SizedBox(height: 8),
            buildText('• 월간랭킹은 매주 초 업데이트되며, 매월 초 확정된 순위가 발표됩니다.', TextType.p14R,
                textColor: textColor, align: TextAlign.left),
            const SizedBox(height: 8),
            buildText('• 연간랭킹은 매월 초 업데이트되며, 매년 초 확정된 순위가 발표됩니다.', TextType.p14R,
                textColor: textColor, align: TextAlign.left),
          ],
        ),
      ),
    ),
  );
}
