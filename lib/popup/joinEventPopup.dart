import 'package:flutter/material.dart';
import 'package:visitkorea/model/userInfo.dart';
import '../common_widgets.dart';
import 'package:provider/provider.dart';
import '../jsonLoader.dart';
import 'package:flutter/cupertino.dart';

OverlayEntry? overlayEntry;

enum ConsentOption { agree, disagree, none }

ConsentOption? selectedOption;

void showjoinEventAcceptPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // 다이얼로그 바깥을 탭하면 닫히도록 설정
    builder: (BuildContext context) {
      return JoinEventPopup();
    },
  );
}

class JoinEventPopup extends StatefulWidget {
  JoinEventPopup({
    Key? key,
  });

  @override
  _JoinEventPopup createState() => _JoinEventPopup();
}

class _JoinEventPopup extends State<JoinEventPopup> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // 입력된 이름이 숫자인지 확인하는 함수
  bool isNameValid(String name) {
    return RegExp(r'^[가-힣]+$').hasMatch(name);
  }

  // 입력된 전화번호가 숫자인지 확인하는 함수
  bool isPhoneNumberValid(String phoneNumber) {
    // 010으로 시작하며 그 뒤에 8자리 숫자가 오는 패턴
    return RegExp(r'^010[0-9]{8}$').hasMatch(phoneNumber);
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            '개인정보 수집 및 이용 동의',
            style: TextStyle(fontFamily: 'NotoSansKR'),
          ),
          content: SingleChildScrollView(
            // 내용이 길어질 수 있으므로 SingleChildScrollView 사용
            child: ListBody(
              // ListBody를 사용하여 자식들이 수직으로 배치되도록 함
              children: <Widget>[
                Text(message, style: TextStyle(fontFamily: 'NotoSansKR')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인',
                  style:
                      TextStyle(color: Colors.blue, fontFamily: 'NotoSansKR')),
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
            ),
          ],
        );
      },
    );
  }

  void pressedOk() async {
    String nameText = nameController.text;
    String phoneNumText = phoneController.text;

    bool isName = isNameValid(nameText);
    bool isPhoneNum = isPhoneNumberValid(phoneNumText);
    bool isAgree = selectedOption == ConsentOption.agree;

    if (isName && isPhoneNum && isAgree) {
      UserPrivacyInfoProvider provider = Provider.of(context, listen: false);
      await provider.updateData(
          UserPrivacyInfo(
            snsQuestInfoId: provider.userPrivacyInfo.snsQuestInfoId,
            isEventAgree: isAgree,
            isPrivacyAgree: isAgree,
            name: nameText,
            phoneNumber: phoneNumText,
            isExposeRank: isAgree,
            isBadgeTesterMode: provider.userPrivacyInfo.isBadgeTesterMode,
          ), () {
        Navigator.of(context).pop(); // 대화상자 닫기
        showAlert('랭킹전 참여 완료되었습니다.');
      });
    } else {
      if (isAgree) {
        showAlert('정확한 정보를 입력해주세요.');
      } else {
        showAlert('동의하지 않을 경우 랭킹전에 참여할 수 없습니다.');
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width > 1000 ? false : true;
    double pWidth = isMobile ? 360 : 650;
    double pHeight =
        (isMobile ? 681 : 780) + MediaQuery.of(context).viewInsets.bottom;

    Widget buildTextRich(String desc) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: desc,
              style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: isMobile ? 13 : 18,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: '(필수)',
              style: TextStyle(
                  color: const Color(0xFFFF3333),
                  fontSize: isMobile ? 13 : 18,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w700),
            )
          ],
        ),
      );
    }

    /// 입력 텍스트 필드
    Widget buildTextField() {
      return Column(children: [
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: nameController,
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const InputDecoration(
              hintText: '이름(한글만 입력 가능)',
              hintStyle: TextStyle(
                color: Color(0xFF999999),
                fontFamily: 'NotoSansKR',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(1),
                  )),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(1))),
            ),
            style: const TextStyle(fontFamily: 'NotoSansKR'),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: phoneController,
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const InputDecoration(
              hintText: "휴대전화번호(구분자 '-'제외한 숫자만 입력 가능)",
              hintStyle: TextStyle(
                color: Color(0xFF999999),
                fontFamily: 'NotoSansKR',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(1))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(1))),
            ),
            style: const TextStyle(fontFamily: 'NotoSansKR'),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ]);
    }

    return Center(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            // 반투명 배경 추가
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: pWidth,
                  //height: pHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: isMobile ? 360 : 650,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      clipBehavior: Clip.antiAlias,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF282B30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: buildText('랭킹전 참여하기', TextType.h6,
                                  textColor: Colors.white,
                                  align: TextAlign.left),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop(); // 대화상자 닫기
                            },
                            child: const Icon(Icons.close,
                                size: 24, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 40,
                          vertical: isMobile ? 25 : 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: buildText('배지콕콕 서비스의 랭킹전에 참여하기 위해',
                                isMobile ? TextType.p12M : TextType.p18R),
                          ),
                          Center(
                            child: buildText('아래 약관을 확인해주세요!',
                                isMobile ? TextType.p12B : TextType.h5),
                          ),
                          SizedBox(height: isMobile ? 25 : 40),
                          Container(
                            width: double.infinity,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFFDDDDDD),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 25 : 40),
                          if (isMobile) ...[
                            buildTextRich('개인 정보 수집 이용 동의'),
                            const SizedBox(height: 10),
                            SizedBox(
                                width: 318,
                                child: CustomCheckBox(isMobile: true))
                          ] else
                            Row(
                              children: [
                                SizedBox(
                                    width: 402,
                                    child: buildTextRich('개인 정보 수집 이용 동의')),
                                const SizedBox(width: 10),
                                SizedBox(
                                    width: 158,
                                    child: CustomCheckBox(isMobile: false))
                              ],
                            ),
                          const SizedBox(height: 10),
                          Container(
                            height: 235,
                            padding: const EdgeInsets.all(20),
                            clipBehavior: Clip.antiAlias,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1, color: Color(0xFFCCCCCC)),
                              ),
                            ),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                        color: Colors.black), // 기본 색상을 정의합니다.
                                    children: <TextSpan>[
                                      // 이 부분은 일반 텍스트 스타일입니다.
                                      TextSpan(
                                          text:
                                              '안녕하세요. 한국관광공사 대한민국 구석구석입니다.\n\n대한민국 구석구석 배지콕콕 서비스 내 랭킹전 참여 및 경품 발송을 위하여 고객님의 개인 정보 수집 및 이용에 관한 동의를 요청 드립니다.\n◎ 수집 목적 : 배지콕콕 서비스 랭킹전 참여(랭킹 순위 제공), 배지콕콕 서비스 우수활동자 대상 경품 증정 목적\n◎ 수집 항목 (필수) : 이름, 휴대전화 번호\n',
                                          style: TextStyle(
                                              fontFamily: 'NotoSansKR')),
                                      TextSpan(
                                          text: '◎ 사용자의 개인 정보 보유 및 이용 기간:',
                                          style: TextStyle(
                                              fontFamily: 'NotoSansKR')),
                                      // 이 부분은 굵은 글씨로 표시됩니다.
                                      TextSpan(
                                        text: ' 개인 정보 수집일로부터 동의 취소 시까지',
                                        style: TextStyle(
                                            fontFamily: 'NotoSansKR',
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline),
                                      ),

                                      // 마무리 부분은 다시 일반 스타일의 텍스트입니다.
                                      TextSpan(
                                          text:
                                              '\n\n고객님께서는 위의 개인정보 수집 및 이용에 대해 동의를 거부할 권리가 있습니다. 그러나 동의를 거부할 경우 배지콕콕 서비스 랭킹전 및 이벤트 참여가 제한될 수 있습니다.\n\n또한, 한국관광공사는 대한민국 구석구석 ‘배지콕콕’ 서비스의 안정적인 운영을 위하여 아래와 같이 개인정보 처리를 위·수탁 하고 있음을 안내드립니다.\n\n◎ 수탁업체명 : (주)유니에스아이엔씨 / 업무 내용 : ‘배지콕콕’ 서비스 운영\n\n위와 같이 개인정보를 수집 및 이용하는 것에 동의합니다.',
                                          style: TextStyle(
                                              fontFamily: 'NotoSansKR')),
                                    ],
                                  ),
                                )),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(height: isMobile ? 24 : 40),
                          buildTextRich('참여정보'),
                          const SizedBox(height: 10),
                          buildTextField(),
                          //const SizedBox(height: 20),
                          SizedBox(height: isMobile ? 25 : 40),
                          buildPopupButton(context),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPopupButton(BuildContext context) {
    return Center(
      child: Container(
        width: 326,
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 대화상자 닫기
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white),
                  fixedSize: MaterialStatePropertyAll(Size(155, 40)),
                  side: MaterialStatePropertyAll(
                      BorderSide(width: 1, color: Color(0xFFCCCCCC))),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStatePropertyAll(Colors.transparent),
                  shadowColor: MaterialStatePropertyAll(Colors.transparent),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
                    ),
                  ),
                ),
                child: buildText('취소', TextType.p16R)),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: () async {
                  pressedOk();
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF001941)),
                  fixedSize: MaterialStatePropertyAll(Size(155, 40)),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStatePropertyAll(Colors.transparent),
                  shadowColor: MaterialStatePropertyAll(Colors.transparent),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
                    ),
                  ),
                ),
                child: buildText('확인', TextType.p16R, textColor: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class CustomCheckBox extends StatefulWidget {
  final bool isMobile;
  CustomCheckBox({required this.isMobile});

  @override
  _CustomCheckBoxState createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  void _setConsent(ConsentOption consent) {
    setState(() {
      selectedOption = consent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _setConsent(ConsentOption.agree),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selectedOption == ConsentOption.agree,
                  onChanged: (bool? newValue) {
                    _setConsent(newValue == true
                        ? ConsentOption.agree
                        : ConsentOption.none);
                  },
                  //activeColor: Colors.transparent,
                ),
                const Text(
                  "동의",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _setConsent(ConsentOption.disagree),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selectedOption == ConsentOption.disagree,
                  onChanged: (bool? newValue) {
                    _setConsent(newValue == true
                        ? ConsentOption.disagree
                        : ConsentOption.none);
                  },
                  //activeColor: Colors.transparent,
                ),
                const Text(
                  "동의안함",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
