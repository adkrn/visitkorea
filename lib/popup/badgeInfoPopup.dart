import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:visitkorea/model/quest.dart';
import '../common_widgets.dart';
import '../jsonLoader.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'package:screenshot/screenshot.dart';
import 'dart:js' as js;

OverlayEntry? overlayEntry;

// void showBadgePopup(BuildContext context, Badge_completed badge) async {
//   // 여기에서 OverlayEntry를 사용하여 팝업을 생성합니다.
//   overlayEntry = OverlayEntry(
//     builder: (context) => BadgeInfoPopup(badge: badge),
//   );

//   // Overlay에 팝업 추가
//   Overlay.of(context)?.insert(overlayEntry!);
// }

void showBadgePopup(BuildContext context, Badge_completed badge) {
  showDialog(
    context: context,
    barrierDismissible: true, // 다이얼로그 바깥을 탭하면 닫히도록 설정
    builder: (BuildContext context) {
      return BadgeInfoPopup(
        badge: badge,
      );
    },
  );
}

// 사용자 정의 팝업 위젯
class BadgeInfoPopup extends StatefulWidget {
  final Badge_completed badge;

  const BadgeInfoPopup({Key? key, required this.badge}) : super(key: key);

  @override
  _BadgeInfoPopupState createState() => _BadgeInfoPopupState();
}

class _BadgeInfoPopupState extends State<BadgeInfoPopup> {
  bool isDownloadPopup = false;

  ScreenshotController screenshotController = ScreenshotController();

  String convertBrToNewline(String htmlString) {
    return htmlString.replaceAll('<br>', '\n');
  }

  void getUserAgent() {
    String userAgent = js.context.callMethod('getUserAgent').toString();
    print('User Agent: $userAgent');

    String downloadUrl = '';
    Uint8List image = Uint8List(0);

    screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((capturedImage) async {
      downloadUrl = downloadImage(capturedImage!);
      image = capturedImage;

      if (downloadUrl == '') {
        print('downloadUrl is empty');
        return;
      }
    }).catchError((onError) {
      print(onError);
    });

    if (userAgent.toLowerCase().contains('iphone') ||
        userAgent.toLowerCase().contains('ipad')) {
      print('iOS');
      js.context.callMethod('downloadImageIos', [downloadUrl]);
    } else if (userAgent.toLowerCase().contains('android')) {
      print('Android');
    } else if (userAgent.toLowerCase().contains('macintosh')) {
      print('iOS');
      js.context.callMethod('downloadImageIos', [downloadUrl]);
    } else if (userAgent.toLowerCase().contains('ipod')) {
      print('iOS');
      js.context.callMethod('downloadImageIos', [downloadUrl]);
    } else {
      print('Other');
      ShowCapturedWidget(image, downloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        !isDownloadPopup
            ?
            // 팝업 컨텐츠
            Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 360,
                    //height: widget.badge.isUse ? 480 : 544,
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
                        buildText(widget.badge.badgeinfo.name, TextType.h4),
                        const SizedBox(height: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildBadgeImage(widget.badge),
                            const SizedBox(height: 8),
                            buildQuestProgressInfo(widget.badge)
                          ],
                        ),
                        const SizedBox(height: 16),
                        buildText(
                            convertBrToNewline(
                                widget.badge.badgeinfo.description),
                            TextType.p16R),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildText(
                                '과제 보상 : 배지, ${widget.badge.badgeinfo.rewardPoint ?? 1}',
                                TextType.h6),
                            const SizedBox(width: 2),
                            Image.asset(
                              'assets/Vector_step.png',
                              width: 16,
                              height: 16,
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Image.asset('assets/PopupLine.png'),
                        const SizedBox(height: 16),
                        buildSetButton(context, widget.badge),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, size: 30),
                        ),
                      ),
                      const Text(
                        '배지 이미지를 저장하여\nSNS에 자랑해보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 56),
                      Screenshot(
                        controller: screenshotController,
                        child: SizedBox(
                          width: 325,
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/badgeFrame/badgeFrame.png',
                                fit: BoxFit.contain,
                              ),
                              Positioned(
                                top: 20,
                                left: 20,
                                right: 20,
                                bottom: 190,
                                child: Image.asset(
                                  'assets/enable/${widget.badge.badgeinfo.imgName}.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                right: 20,
                                left: 20,
                                bottom: 160,
                                child: Text(
                                  context
                                      .read<UserInfoProvider>()
                                      .userInfo
                                      .snsUserName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'NotoSansKR',
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Positioned(
                                right: 66,
                                left: 20,
                                bottom: 105,
                                child: Text(
                                  widget.badge.badgeinfo.name,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'NotoSansKR',
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Positioned(
                                right: 66,
                                left: 20,
                                bottom: 78,
                                child: Text(
                                  getTimeStamp(widget.badge.createDate),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'NotoSansKR',
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 56),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001941),
                          fixedSize: const Size(325, 40),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                        child: const Text(
                          '사진으로 저장하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          getUserAgent();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  String getTimeStamp(DateTime createDate) {
    String formattedDate = DateFormat("yyyy년 M월 d일").format(createDate);
    return formattedDate;
  }

  String downloadImage(Uint8List capturedImage) {
    final blob = html.Blob([capturedImage], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    return url;
  }

  void ShowCapturedWidget(Uint8List capturedImage, String url) {
    html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(
            html.Blob([capturedImage], 'image/png')))
      ..setAttribute("download", "captured_image.png")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Widget buildSetButton(BuildContext context, Badge_completed badge) {
    return SizedBox(
      width: 326,
      //height: badge.isUse ? 42 : 92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (badge.isUse == false) ...[
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false, // 다이얼로그 바깥을 탭해도 닫히지 않도록 설정
                  builder: (BuildContext context) {
                    // 확인/취소 버튼이 있는 AlertDialog 생성
                    return CupertinoAlertDialog(
                      title: const Text('대표 배지로 설정하시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('취소'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                        ),
                        TextButton(
                          child: const Text(
                            '확인',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                            // 대표 배지 설정 로직을 여기에 추가하세요.
                            Provider.of<BadgeProvider>(context, listen: false)
                                .setMainBadge(badge.badgeSnsId, openDialog);
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
                fixedSize: MaterialStatePropertyAll(Size(640, 42)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
                  ),
                ),
              ),
              child: buildText(
                '대표배지 설정하기',
                TextType.p16M,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: () {
              setState(() {
                isDownloadPopup = true;
              });
            },
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.white),
              fixedSize: MaterialStatePropertyAll(Size(640, 40)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 1),
                  borderRadius:
                      BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
                ),
              ),
            ),
            child: buildText(
              '배지 이미지 저장하기',
              TextType.p16M,
              textColor: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.black),
              fixedSize: MaterialStatePropertyAll(Size(640, 40)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
                ),
              ),
            ),
            child: buildText(
              '확인',
              TextType.p16M,
              textColor: Colors.white,
            ),
          ),
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
              child: Text('확인'),
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
}

Widget buildBadgeImage(Badge_completed badge) {
  const String baseUrl = 'assets/';
  String imageUrl = '${baseUrl}enable/${badge.badgeinfo.imgName}.png';

  return SizedBox(
      width: 160,
      height: 160,
      child: Image.asset(imageUrl, fit: BoxFit.contain));
}

Widget buildQuestProgressInfo(Badge_completed badge) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 이 부분은 배지 액션 타입을 불러와서 처리해야할듯.
      buildText(badge.badgeinfo.name, TextType.p16M),
      const SizedBox(width: 8),
      buildText('도전 성공!', TextType.h6, textColor: const Color(0xFF7845E2))
    ],
  );
}
