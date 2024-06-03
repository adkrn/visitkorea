import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:visitkorea/model/quest.dart';
import '../common_widgets.dart';
import '../jsonLoader.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:js' as js;

OverlayEntry? overlayEntry;

void showBadgePopup(BuildContext context, Badge_completed badge) {
  showDialog(
    context: context,
    barrierDismissible: true,
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
  var blob;
  var blobUrl;

  ScreenshotController screenshotController = ScreenshotController();

  String convertBrToNewline(String htmlString) {
    return htmlString.replaceAll('<br>', '\n');
  }

  void getUserAgent() async {
    String userAgent = js.context.callMethod('getUserAgent').toString();
    print('User Agent: $userAgent');

    return Future.delayed(
      const Duration(milliseconds: 20),
      () async {
        void showDebugAlert(String debuglog) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text(
                  '다운로드 에러',
                  style: TextStyle(fontFamily: 'NotoSansKR'),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(debuglog,
                          style: TextStyle(fontFamily: 'NotoSansKR')),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('확인',
                        style: TextStyle(
                            fontFamily: 'NotoSansKR', color: Colors.blue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }

        Map<String, dynamic> queryParameters = {
          'badgeSnsId': widget.badge.badgeSnsId,
          'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
        };
        final url = Uri.http(domain, '/quest-api/v1/image', queryParameters);
        try {
          var response = await http.get(
            url,
            headers: {
              'SNS_ID': '${userSession?.snsId}',
              'Cache-Control': 'no-store',
              'Pragma': 'no-store',
              'Expires': '0',
            },
          );

          if (response.statusCode == 200) {
            blob = html.Blob([response.bodyBytes]);
            blobUrl = html.Url.createObjectUrl(blob);
            bool isApp = userAgent.toLowerCase().contains('visitkor');

            if (isApp) {
              print('웹뷰에서는 jsMethod 실행');
              if (userAgent.toLowerCase().contains('iphone') ||
                  userAgent.toLowerCase().contains('ipad')) {
                print('iOS Blob url in flutter :: $blobUrl');
                js.context.callMethod('downloadImageIos', [blob]);
              } else if (userAgent.toLowerCase().contains('android')) {
                print('Android Blob url in flutter :: $blobUrl');
                js.context.callMethod('downloadImageAndroid', [blob]);
              } else {
                print('Other');
                ShowCapturedWidget(response.bodyBytes, blobUrl);
              }
            } else {
              print('웹에서는 ShowCapturedWidget 실행');
              ShowCapturedWidget(response.bodyBytes, blobUrl);
            }
          }
        } catch (e) {
          showDebugAlert('User Agent: $userAgent\n error : $e');
          print('error : $e');
        }
      },
    );
  }

  var src = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String url = '';

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
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
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
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ),
                      const Text(
                        '배지 이미지를 저장하여\nSNS에 자랑해보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 24),
                      Screenshot(
                        controller: screenshotController,
                        child: RepaintBoundary(
                          key: src,
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
                      ),
                      const SizedBox(height: 24),
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
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text(
                        '대표 배지로 설정하시겠습니까?',
                        style: TextStyle(fontFamily: 'NotoSansKR'),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('취소',
                              style: TextStyle(fontFamily: 'NotoSansKR')),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            '확인',
                            style: TextStyle(
                                fontFamily: 'NotoSansKR', color: Colors.blue),
                          ),
                          onPressed: () {
                            Provider.of<BadgeProvider>(context, listen: false)
                                .setMainBadge(badge.badgeSnsId, openDialog);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xFF7845E2)),
                fixedSize: MaterialStatePropertyAll(Size(640, 42)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
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
                  borderRadius: BorderRadius.all(Radius.circular(3)),
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
              Navigator.of(context).pop();
            },
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.black),
              fixedSize: MaterialStatePropertyAll(Size(640, 40)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
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
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            '설정 완료',
            style: TextStyle(fontFamily: 'NotoSansKR'),
          ),
          content: Text(
            '대표 배지로 설정되었습니다.',
            style: TextStyle(fontFamily: 'NotoSansKR'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '확인',
                style: TextStyle(fontFamily: 'NotoSansKR'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
      buildText(badge.badgeinfo.name, TextType.p16M),
      const SizedBox(width: 8),
      buildText('도전 성공!', TextType.h6, textColor: const Color(0xFF7845E2))
    ],
  );
}
