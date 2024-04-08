import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visitkorea/model/quest.dart';
import '../common_widgets.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../jsonLoader.dart';

OverlayEntry? overlayEntry;
OverlayEntry? alertOverlayEntry;

enum QuestPopupType {
  unProgressed,
  progress,
  completed,
  receive,
  setMainBadge,
  vip
}

QuestPopupType questPopupType = QuestPopupType.unProgressed;

// void showQeustPopup(BuildContext context, Quest quest) async {
//   // 여기에서 OverlayEntry를 사용하여 팝업을 생성합니다.
//   overlayEntry = OverlayEntry(
//     builder: (context) => QuestInfoPopup(quest: quest),
//   );

//   // Overlay에 팝업 추가
//   Overlay.of(context)?.insert(overlayEntry!);
// }

void showQuestPopup(BuildContext context, Quest quest) {
  showDialog(
    context: context,
    barrierDismissible: true, // 다이얼로그 바깥을 탭하면 닫히도록 설정
    builder: (BuildContext context) {
      return QuestInfoPopup(
        quest: quest,
      );
    },
  );
}

// 사용자 정의 팝업 위젯
class QuestInfoPopup extends StatefulWidget {
  final Quest quest;

  QuestInfoPopup({Key? key, required this.quest}) : super(key: key);

  @override
  _QuestInfoPopupState createState() => _QuestInfoPopupState();
}

class _QuestInfoPopupState extends State<QuestInfoPopup> {
  String convertBrToNewline(String htmlString) {
    return htmlString.replaceAll('<br>', '\n');
  }

  double setHeightByType() {
    double heightValue;

    switch (widget.quest.progressType) {
      case ProgressType.unProgressed:
        questPopupType = QuestPopupType.unProgressed;
        heightValue = 610;
        break;

      case ProgressType.progress:
        questPopupType = QuestPopupType.progress;
        heightValue = 610;
        break;

      case ProgressType.completed:
        questPopupType = QuestPopupType.completed;
        heightValue = 498.4;
        break;

      case ProgressType.receive:
        // 대표배지가 설정되있고, 설정된 대표배지가 있는지 확인.
        if (mainBadge?.badgeinfo.badgeId ==
                widget.quest.questDetails.enableBadge?.badgeId &&
            Provider.of<BadgeProvider>(context, listen: false).isSetMainBadge) {
          questPopupType = QuestPopupType.setMainBadge;
          heightValue = 498.4;
        } else {
          questPopupType = QuestPopupType.receive;
          heightValue = 548;
        }
        break;

      default:
        heightValue = 610; // 기본값 설정 (예상치 못한 상황에 대비)
    }

    // 이벤트 타입의 경우 추가 높이 조정
    if (widget.quest.questDetails.questType == QuestType.event) {
      heightValue += 30;
    }

    return heightValue;
  }

  void setPopupType() {
    switch (widget.quest.progressType) {
      case ProgressType.unProgressed:
        questPopupType = QuestPopupType.unProgressed;
        break;

      case ProgressType.progress:
        questPopupType = QuestPopupType.progress;
        break;

      case ProgressType.completed:
        questPopupType = QuestPopupType.completed;
        break;

      case ProgressType.receive:
        // 대표배지가 설정되있고, 설정된 대표배지가 있는지 확인.
        if (mainBadge?.badgeinfo.badgeId ==
                widget.quest.questDetails.enableBadge?.badgeId &&
            Provider.of<BadgeProvider>(context, listen: false).isSetMainBadge) {
          questPopupType = QuestPopupType.setMainBadge;
        } else {
          questPopupType = QuestPopupType.receive;
        }
        break;
      case ProgressType.expiration:
      // TODO: Handle this case.
    }

    if (widget.quest.questDetails.conditionName == '대구석VIP 달성하기') {
      if (widget.quest.progressType != ProgressType.completed)
        questPopupType = QuestPopupType.vip;
    }
  }

  @override
  Widget build(BuildContext context) {
    setPopupType();
    return Stack(
      children: [
        // 반투명 배경 추가
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // 팝업 컨텐츠
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 360,
              //height: setHeightByType(),
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
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                    ),
                  ),
                  buildText(widget.quest.questDetails.name, TextType.h4),
                  if (widget.quest.questDetails.questType == QuestType.event)
                    buildText(
                        '${widget.quest.questDetails.activationStartDate.substring(5, 10)} ~ ${widget.quest.questDetails.activationEndDate.substring(5, 10)}',
                        TextType.h4,
                        textColor: const Color(0xFF7845E2)),
                  const SizedBox(height: 16),
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildBadgeImage(widget.quest),
                        buildQuestProgressInfo(widget.quest)
                      ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 320,
                    child: buildText(
                        convertBrToNewline(
                            widget.quest.questDetails.description),
                        TextType.p16R),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildText(
                          questPopupType != QuestPopupType.vip
                              ? '과제 보상 : ${widget.quest.questDetails.grade != '반복' ? '배지,' : ''} ${widget.quest.questDetails.rewardPoint}'
                              : '과제 보상 : 배지',
                          TextType.h6),
                      if (questPopupType != QuestPopupType.vip) ...[
                        const SizedBox(width: 2),
                        Image.asset(
                          'assets/Vector_step.png',
                          width: 16,
                          height: 16,
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 16),
                  Image.asset('assets/PopupLine.png'),
                  const SizedBox(height: 16),
                  if (widget.quest.progressType.index < 2) ...[
                    buildGetMethodDescription(widget.quest),
                    const SizedBox(height: 16),
                  ],
                  buildSetButtonByProgressType(context, widget.quest),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSetButtonByProgressType(BuildContext context, Quest quest) {
    return Container(
      width: 326,
      height: questPopupType == QuestPopupType.receive ? 92 : 42,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (questPopupType == QuestPopupType.receive) ...[
            ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // 다이얼로그 바깥을 탭해도 닫히지 않도록 설정
                    builder: (BuildContext context) {
                      // 확인/취소 버튼이 있는 AlertDialog 생성
                      return CupertinoAlertDialog(
                        title: Text('대표 배지를 설정하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('취소'),
                            onPressed: () {
                              Navigator.of(context).pop(); // 다이얼로그 닫기
                            },
                          ),
                          TextButton(
                            child: Text('확인',
                                style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              // 대표 배지 설정 로직을 여기에 추가하세요.
                              Provider.of<BadgeProvider>(context, listen: false)
                                  .setMainBadge(
                                      Provider.of<BadgeProvider>(context,
                                              listen: false)
                                          .badgeList
                                          .where((e) =>
                                              e.badgeinfo.badgeId ==
                                              widget.quest.questDetails
                                                  .enableBadge?.badgeId)
                                          .single
                                          .badgeSnsId,
                                      openDialog);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  //Navigator.of(context).pop(); // 팝업 닫기
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF7845E2)),
                  fixedSize: MaterialStatePropertyAll(Size(640, 40)),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(5)), // 모서리를 사각형으로 설정
                    ),
                  ),
                ),
                child: buildText(
                  '대표배지 설정하기',
                  TextType.p16M,
                  textColor: Colors.white,
                )),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () {
                  // overlayEntry?.remove(); // OverlayEntry 제거
                  // overlayEntry = null;
                  Navigator.of(context).pop();
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.black),
                  fixedSize: MaterialStatePropertyAll(Size(640, 40)),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(5)), // 모서리를 사각형으로 설정
                    ),
                  ),
                ),
                child: buildText(
                  '확인',
                  TextType.p16M,
                  textColor: Colors.white,
                )),
          ] else ...[
            if (questPopupType == QuestPopupType.completed)
              ElevatedButton(
                  onPressed: () async {
                    Provider.of<QuestProvider>(context, listen: false)
                        .completeQuest(context, quest.questSnsId, () {
                      // completeQuest가 성공적으로 완료된 후에 호출될 콜백
                      Provider.of<QuestProvider>(context, listen: false)
                          .refreshQuests();
                      Provider.of<BadgeProvider>(context, listen: false)
                          .refreshBadges();
                      Provider.of<UserInfoProvider>(context, listen: false)
                          .refreshData();
                    });
                    //Navigator.of(context).pop(); // 팝업 닫기
                  },
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Color(0xFF7845E2)),
                    fixedSize: MaterialStatePropertyAll(Size(640, 40)),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(5)), // 모서리를 사각형으로 설정
                      ),
                    ),
                  ),
                  child: buildText(
                      quest.questDetails.grade == '반복' ? '보상 수령하기' : '배지 수령하기',
                      TextType.p16M,
                      textColor: Colors.white))
            else
              ElevatedButton(
                  onPressed: () {
                    // overlayEntry?.remove(); // OverlayEntry 제거
                    // overlayEntry = null;
                    Navigator.of(context).pop();
                  },
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.black),
                    fixedSize: MaterialStatePropertyAll(Size(640, 40)),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(5)), // 모서리를 사각형으로 설정
                      ),
                    ),
                  ),
                  child:
                      buildText('확인', TextType.p16M, textColor: Colors.white)),
          ],
        ],
      ),
    );
  }

  void openDialog() {
    Navigator.of(context).pop(); // 알럿 닫기
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 다이얼로그 바깥을 탭해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('설정 완료'),
          content: Text('대표 배지로 설정되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // 알럿 닫기
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildBadgeImage(Quest quest) {
    const String baseUrl = 'assets/';
    ProgressType progressType = quest.progressType;

    String getImageUrl(ProgressType type) {
      switch (type) {
        case ProgressType.unProgressed:
          if (quest.questDetails.grade == '반복') {
            if (quest.questDetails.conditionName == '대구석VIP 달성하기') {
              return '${baseUrl}unknown/${quest.questDetails.unknownBadge!.imgName}.png';
            } else {
              return '${baseUrl}unknown/img_badge_point_unknown.png';
            }
          } else {
            return '${baseUrl}unknown/${quest.questDetails.unknownBadge!.imgName}.png';
          }
        case ProgressType.progress:
          if (quest.questDetails.grade == '반복') {
            return '${baseUrl}disable/img_badge_point_disable.png';
          } else {
            return '${baseUrl}disable/${quest.questDetails.disableBadge!.imgName}.png';
          }
        case ProgressType.completed:
          if (quest.questDetails.grade == '반복') {
            if (quest.questDetails.conditionName == '대구석VIP 달성하기') {
              return '${baseUrl}unknown/${quest.questDetails.unknownBadge!.imgName}.png';
            } else {
              return '${baseUrl}enable/img_badge_point_enable.png';
            }
          } else {
            return '${baseUrl}enable/${quest.questDetails.enableBadge!.imgName}.png';
          }
        case ProgressType.receive:
          return '${baseUrl}enable/${quest.questDetails.enableBadge!.imgName}.png';
        default:
          throw Exception('잘못된 퀘스트 정보입니다.');
      }
    }

    // 기간 만료 체크
    bool isExpiration = DateTime.now()
        .isAfter(DateTime.parse(quest.questDetails.activationEndDate));
    String imageUrl = getImageUrl(progressType);

    return Container(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (progressType == ProgressType.completed)
            Image.asset(
              '${baseUrl}animation.gif',
              width: 160,
              height: 160,
              fit: BoxFit.fill,
            ),
          Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
          // 기간 만료 일때 이미지 위에 기간 만료 표시.
          if (isExpiration) ...[
            Image.asset(
              imageUrl,
              fit: BoxFit.fill,
              color: Colors.black26,
            ),
            Image.asset('assets/image_Expiration.png')
          ]
        ],
      ),
    );
  }

  Widget buildQuestProgressInfo(Quest quest) {
    ProgressType progressType = quest.progressType;
    double progress = quest.actionCount / quest.questDetails.actionCountValue;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          buildText(quest.questDetails.conditionName, TextType.h6),
          const SizedBox(width: 8),
          if (progressType.index > 1)
            buildText('도전 성공!', TextType.h6, textColor: const Color(0xFF7845E2))
          else
            quest.questDetails.conditionName != '대구석VIP 달성하기'
                ? buildProgressText(quest)
                : SizedBox(),
        ],
      ),
      if (progressType.index < 2 &&
          quest.questDetails.conditionName != '대구석VIP 달성하기') ...[
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6), // 모서리 둥글기
          child: SizedBox(
            width: 230,
            height: 12,
            child: LinearProgressIndicator(
              value: progress, // 현재 진행률
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF7845E2)),
            ),
          ),
        ),
      ],
    ]);
  }

  Widget buildGetMethodDescription(Quest quest) {
    // '획득방법'을 분리
    var splitDescription =
        quest.questDetails.getMethodDescription.split('<br>');
    String details = splitDescription.skip(0).join('\n'); // 나머지 설명

    return Container(
      width: 326,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildText('획득방법', TextType.h5, align: TextAlign.left),
          const SizedBox(height: 4),
          SingleChildScrollView(
            child: buildText(details, TextType.p14R,
                textColor: Colors.black, align: TextAlign.left),
          ),
        ],
      ),
    );
  }

  Widget buildProgressText(Quest quest) {
    Color actionCountColor = quest.actionCount > 0
        ? const Color(0xFF7845E2)
        : const Color(0xFF999999);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // actionCount 부분
        buildText(
          '${quest.actionCount}',
          TextType.h6,
          textColor: actionCountColor,
        ),
        const SizedBox(width: 8),
        Image.asset('assets/popupTextLine.png'),
        const SizedBox(width: 8),
        // 슬래시(/) 및 actionCountValue 부분
        buildText('${quest.questDetails.actionCountValue}', TextType.h6),
      ],
    );
  }
}
