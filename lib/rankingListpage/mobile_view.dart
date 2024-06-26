import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitkorea/jsonLoader.dart';
import 'package:visitkorea/model/userRankingInfo.dart';
import 'rankingListPage.dart';
import '../common_widgets.dart';
import 'package:intl/intl.dart';

class MobileLayout_rankingList extends StatefulWidget {
  @override
  _MobileLayoutState_rankingList createState() =>
      _MobileLayoutState_rankingList();
}

class _MobileLayoutState_rankingList extends State<MobileLayout_rankingList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildTitleBanner(context),
          buildRankInfoText(),
          buildRankGridList(),
          buildRankNoticeSection(),
        ],
      ),
    );
  }

  Widget buildTitleBanner(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFFEDEFFB)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTitleBannerTitle(),
            const SizedBox(height: 16),
            buildTopRankingList(),
          ],
        ));
  }

  Widget buildTitleBannerTitle() {
    var provider = Provider.of<RankingProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildText('랭킹', TextType.h4),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                content: const SingleChildScrollView(
                                  // 내용이 길어질 수 있으므로 SingleChildScrollView 사용
                                  child: ListBody(
                                    // ListBody를 사용하여 자식들이 수직으로 배치되도록 함
                                    children: <Widget>[
                                      Text(
                                          '랭킹전은 월간/연간 랭킹으로 운영되며, 랭킹점수가 동일할 경우 배지 보유량으로 순위가 결정됩니다.',
                                          style: TextStyle(
                                              fontFamily: 'NotoSansKR')),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('확인',
                                        style: TextStyle(
                                            fontFamily: 'NotoSansKR',
                                            color: Colors.blue)),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 대화상자 닫기
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.black,
                          size: 16,
                        ),
                      )
                    ],
                  ),
                ),
                CustomDropdownMenu(
                  menuItems: const ['연간', '월간'],
                  initialValue: '월간',
                  isEnable: true,
                  onItemSelected: (String selectedValue) {
                    //print("선택된 값: $selectedValue");
                    provider.refreshData(selectedValue == '월간' ? 'M' : 'Y');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopRankingList() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildTopRankBox(1),
          const SizedBox(width: 8),
          buildTopRankBox(0),
          const SizedBox(width: 8),
          buildTopRankBox(2),
        ],
      ),
    );
  }

  Widget buildTopRankBox(int num) {
    bool isNotTop = num > 0;

    return Consumer<RankingProvider>(
      builder: (context, rankingProvider, child) {
        if (rankingProvider.isLoading) {
          return SizedBox();
        }
        List<UserRankingInfo> userList = rankingProvider.userList;
        if (userList.isEmpty || userList.length <= num) {
          //print('userList 없음');
          return SizedBox();
        }
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 110,
              //height: isNotTop ? 158 : 171,
              padding: const EdgeInsets.only(
                  top: 24, right: 16, left: 16, bottom: 16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFE6E6E6)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (userList[num].mainBadgeName != null) ...[
                    SizedBox(
                      width: isNotTop ? 64 : 80,
                      child: Image.asset(
                        'assets/enable/${userList[num].mainBadgeName!.badgeinfo.imgName}_160.png',
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/userIcon.png',
                              fit: BoxFit.fitWidth);
                        },
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: isNotTop ? 60 : 80,
                      height: isNotTop ? 60 : 80,
                      padding: const EdgeInsets.all(12),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF6F6F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42),
                        ),
                      ),
                      child: SizedBox(
                        //width: (isNotTop ? 32 : 40),
                        //height: (isNotTop ? 32 : 40),
                        child: Image.asset(
                          'assets/userIcon.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ],
                  if (!isNotTop) const SizedBox(height: 2),
                  buildText(userList[num].sns.name, TextType.p14M,
                      isEllipsis: true),
                  SizedBox(height: isNotTop ? 8 : 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: isNotTop
                          ? const Color(0xFFCBD8FF)
                          : const Color(0xFF4E75EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: Image.asset(
                            'assets/Vector_step.png',
                            color: Colors.white,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 4),
                        buildText(
                            NumberFormat('###,###,###,###')
                                .format(userList[num].point),
                            TextType.p12B,
                            textColor: Colors.white),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: -14,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                decoration: ShapeDecoration(
                  color: isNotTop
                      ? const Color(0xFFCACACA)
                      : const Color(0xFF4E75EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: buildText(
                  '${num + 1}',
                  TextType.p12B,
                  textColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildRankInfoText() {
    // RankingProvider 인스턴스가 필요하므로, Provider.of<RankingProvider>(context)로 접근하거나 다른 방식으로 RankingProvider에 접근해야 합니다.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFFF6F6F6)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Consumer<RankingProvider>(
            builder: (context, value, child) {
              if (value.isLoading) {
                return buildText(
                  '불러오는중..',
                  TextType.p12R,
                  textColor: const Color(0xFF7D7D7D),
                );
              }

              String formattedString = DateFormat("yyyy년 MM월 dd일 HH시mm분")
                  .format(value.groupsInfo.confirmDate);
              return buildText(
                '현재 랭킹 : $formattedString 기준 ',
                TextType.p12R,
                textColor: const Color(0xFF7D7D7D),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildRankGridList() {
    return Consumer<RankingProvider>(
      builder: (context, rankingProvider, child) {
        List<UserRankingInfo> userList = [];
        if (rankingProvider.isLoading) {
          return const Column(children: [
            SizedBox(height: 300),
            CircularProgressIndicator(),
            SizedBox(height: 300),
          ]);
        }

        userList = rankingProvider.userList;
        if (userList.isEmpty) {
          return const Column(children: [
            SizedBox(height: 300),
            CircularProgressIndicator(),
            SizedBox(height: 300),
          ]);
        }
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < userList.length; i++)
                buildRankGridItem(userList[i]),
            ]);
      },
    );
  }

  Widget buildRankGridItem(UserRankingInfo userRankingInfo) {
    int rank = userRankingInfo.ranking;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: buildText('$rank', TextType.p16R,
                        align: TextAlign.left),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (userRankingInfo.mainBadgeName != null) ...[
                        SizedBox(
                          width: 48,
                          child: Image.asset(
                            'assets/enable/${userRankingInfo.mainBadgeName!.badgeinfo.imgName}_160.png',
                            fit: BoxFit.fitWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/userIcon.png',
                                fit: BoxFit.contain,
                                color: Color(0xffC3C3C3),
                              );
                            },
                          ),
                        )
                      ] else ...[
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(12),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE2E2E2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(42),
                            ),
                          ),
                          child: Image.asset(
                            'assets/userIcon.png',
                            fit: BoxFit.contain,
                            color: Color(0xffC3C3C3),
                          ),
                        ),
                      ],
                      const SizedBox(width: 24),
                      SizedBox(
                        height: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildText(userRankingInfo.sns.name, TextType.p14M),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    width: 24,
                                    height: 24,
                                    'assets/Vector_step.png'),
                                const SizedBox(width: 4),
                                buildText(
                                    '${NumberFormat('###,###,###,###').format(userRankingInfo.point)}보',
                                    TextType.p14R),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (userRankingInfo.mainBadgeName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF4E75EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildText(
                        userRankingInfo.mainBadgeName!.badgeinfo.name,
                        TextType.p12R,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xFFEAEAEA),
              ),
            ),
          ),
        )
      ],
    );
  }
}
