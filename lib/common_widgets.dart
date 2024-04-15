import '../activityHistory/userActivityHistory.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'popup/joinEventPopup.dart';
import 'package:visitkorea/questListPage/questListPage.dart';
import 'main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'jsonLoader.dart';
import 'introPage.dart';
import 'dart:js' as js;

double widthSize = 1920;

Widget buildTitleBannerImg(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double imageWidth = widthSize;
  double buttonWidth = 450;
  double buttonhight = 90;

  double maxTopPos = 630;
  double maxBottomPos = 80;
  double maxHorizPos = 735;

  double containerWidth = screenWidth * (buttonWidth / imageWidth);
  double containerHeight = containerWidth * (buttonhight / buttonWidth);

  double topPosition = screenWidth * (maxTopPos / imageWidth);
  if (topPosition > maxTopPos) topPosition = maxTopPos;
  double bottomPosition = screenWidth * (maxBottomPos / imageWidth);
  if (bottomPosition > maxBottomPos) bottomPosition = maxBottomPos;
  double leftPosition = screenWidth * (maxHorizPos / imageWidth);
  if (leftPosition > maxHorizPos) leftPosition = maxHorizPos;
  double rightPosition = screenWidth * (maxHorizPos / imageWidth);
  if (rightPosition > maxHorizPos) rightPosition = maxHorizPos;

  return Center(
    child: Stack(children: [
      Image.asset('assets/BadgeBanner_Desktop.png', fit: BoxFit.contain),
      Positioned(
        top: topPosition,
        bottom: bottomPosition,
        left: leftPosition,
        right: rightPosition,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => IntroPage()));
          },
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
          ),
        ),
      ),
    ]),
  );
}

Widget buildTitleBannerImg_mobile(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double imageWidth = 390;
  double buttonWidth = 225;
  double buttonhight = 54;

  double maxTopPos = 198;
  double maxBottomPos = 10;
  double maxHorizPos = 82;

  double containerWidth = screenWidth * (buttonWidth / imageWidth);
  double containerHeight = containerWidth * (buttonhight / buttonWidth);

  double topPosition = screenWidth * (maxTopPos / imageWidth);
  if (topPosition > maxTopPos) topPosition = maxTopPos;
  double bottomPosition = screenWidth * (maxBottomPos / imageWidth);
  if (bottomPosition > maxBottomPos) bottomPosition = maxBottomPos;
  double leftPosition = screenWidth * (maxHorizPos / imageWidth);
  if (leftPosition > maxHorizPos) leftPosition = maxHorizPos;
  double rightPosition = screenWidth * (maxHorizPos / imageWidth);
  if (rightPosition > maxHorizPos) rightPosition = maxHorizPos;

  return Center(
    child: Stack(children: [
      Image.asset('assets/BadgeBanner_Mobile.png', fit: BoxFit.contain),
      Positioned(
        top: topPosition,
        bottom: bottomPosition,
        left: leftPosition,
        right: rightPosition,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => IntroPage()));
          },
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
          ),
        ),
      ),
    ]),
  );
}

Widget buildEventBaaner(isMobile, BuildContext context, double screenSize) {
  return Center(
    child: SizedBox(
      width: isMobile ? 406 * (screenSize / 390) : 1000,
      child: InkWell(
        onTap: () {
          showjoinEventAcceptPopup(context);
        },
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Image.asset(
          isMobile
              ? 'assets/Event_Banner_Mobile.png'
              : 'assets/Event_Banner_PC.png',
          fit: BoxFit.fitWidth,
        ),
      ),
    ),
  );
}

Widget buildNoticeSection_Mobile() {
  Color textColor = const Color(0xFF7D7D7D);

  return Container(
    width: 940,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    color: const Color(0xfff7f7f7),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText('유의사항', TextType.h5),
        const SizedBox(height: 16),
        buildText('• 배지콕콕 서비스는 대한민국 구석구석 로그인 사용자만 참여 가능합니다.', TextType.p14R,
            textColor: textColor, align: TextAlign.left),
        const SizedBox(height: 8),
        buildText('• 배지 및 랭킹점수는 대한민국 구석구석 내 활동내역을 바탕으로 지급됩니다.', TextType.p14R,
            textColor: textColor, align: TextAlign.left),
        const SizedBox(height: 8),
        buildText(
            '• 불법적이거나 정상적이지 않은 방법으로 도전과제를 수행한 경우, 배지와 랭킹점수가 모두 회수될 수 있습니다.',
            TextType.p14R,
            textColor: textColor,
            align: TextAlign.left),
        const SizedBox(height: 8),
        buildText('• 랭킹전 및 경품 이벤트는 개인정보 수집 및 이용 동의자만 참여 가능합니다.', TextType.p14R,
            textColor: textColor, align: TextAlign.left),
        const SizedBox(height: 8),
        buildText(
            '• 배지콕콕 랭킹전 참여 취소 후 동일한 정보로 재 참여 신청 시, 이전에 수행 및 획득했던 내역은 연동이 불가합니다.',
            TextType.p14R,
            textColor: textColor,
            align: TextAlign.left),
        const SizedBox(height: 8),
        buildText(
            '• 배지콕콕 서비스는 로그인 SNS 계정에 따라 활동 데이터가 누적됩니다. 여러 계정을 사용하여 로그인하는 경우, 배지 및 랭킹점수는 각 계정별로 누적되며, 서로 연동되지 않습니다.',
            TextType.p14R,
            textColor: textColor,
            align: TextAlign.left),
        const SizedBox(height: 8),
        buildText('• 배지콕콕 메인 페이지의 닉네임 하단에 있는 랭킹점수를 클릭하면, 활동내역을 확인할 수 있습니다. ',
            TextType.p14R,
            textColor: textColor, align: TextAlign.left),
        const SizedBox(height: 8),
        buildText(
            '• 대구석 첫걸음(회원가입), 지역 명예 주민(디지털 관광주민증 발급), 구독 준비 완료(가볼래-터 구독) 배지의 경우 기존 활동내역도 소급 적용됩니다. 그 외 배지콕콕 서비스 이전의 활동내역은 소급 적용되지 않습니다.',
            TextType.p14R,
            textColor: textColor,
            align: TextAlign.left),
      ],
    ),
  );
}

Widget buildNoticeSection_Desktop() {
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
            buildText('유의사항', TextType.h5),
            const SizedBox(height: 16),
            buildText('• 배지콕콕 서비스는 대한민국 구석구석 로그인 사용자만 참여 가능합니다.', TextType.p14R,
                textColor: const Color(0xFF7D7D7D), align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 배지 및 랭킹점수는 대한민국 구석구석 내 활동내역을 바탕으로 지급됩니다.', TextType.p14R,
                textColor: const Color(0xFF7D7D7D), align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 불법적이거나 정상적이지 않은 방법으로 도전과제를 수행한 경우, 배지와 랭킹점수가 모두 회수될 수 있습니다.',
                TextType.p14R,
                textColor: const Color(0xFF7D7D7D),
                align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 랭킹전 및 경품 이벤트는 개인정보 수집 및 이용 동의자만 참여 가능합니다.', TextType.p14R,
                textColor: const Color(0xFF7D7D7D), align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 배지콕콕 랭킹전 참여 취소 후 동일한 정보로 재 참여 신청 시, 이전에 수행 및 획득했던 내역은 연동이 불가합니다.',
                TextType.p14R,
                textColor: const Color(0xFF7D7D7D),
                align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 배지콕콕 서비스는 로그인 SNS 계정에 따라 활동 데이터가 누적됩니다. 여러 계정을 사용하여 로그인하는 경우, 배지 및 랭킹점수는 각 계정별로 누적되며, 서로 연동되지 않습니다.',
                TextType.p14R,
                textColor: const Color(0xFF7D7D7D),
                align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 배지콕콕 메인 페이지의 닉네임 하단에 있는 랭킹점수를 클릭하면, 활동내역을 확인할 수 있습니다. ',
                TextType.p14R,
                textColor: const Color(0xFF7D7D7D),
                align: TextAlign.left),
            const SizedBox(height: 8),
            buildText(
                '• 대구석 첫걸음(회원가입), 지역 명예 주민(디지털 관광주민증 발급), 구독 준비 완료(가볼래-터 구독) 배지의 경우 기존 활동내역도 소급 적용됩니다. 그 외 배지콕콕 서비스 이전의 활동내역은 소급 적용되지 않습니다.',
                TextType.p14R,
                textColor: const Color(0xFF7D7D7D),
                align: TextAlign.left),
          ],
        ),
      ),
    ),
  );
}

// 배지도감 상단 대표배지
Widget buildRepresentativebadgesCard(bool isMobile) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
    decoration: const BoxDecoration(
      // 하단에만 테두리 선을 추가
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFEEEEEE), // 선의 색상 설정
          width: 1.0, // 선의 두께 설정
        ),
      ),
    ),
    child: Consumer<BadgeProvider>(
      builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildText(
              '나의 대표 배지',
              isMobile ? TextType.h3 : TextType.h2,
            ),
            const SizedBox(height: 8),
            buildText('획득한 배지를 클릭하여\n나의 대표배지로 설정할 수 있어요.', TextType.p16R),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0xFFD9DFFF),
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Image.asset(
                value.isSetMainBadge
                    ? 'assets/enable/${mainBadge?.badgeinfo.imgName}.png'
                    : 'assets/LockIcon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.isSetMainBadge
                  ? '${mainBadge?.badgeinfo.name}'
                  : '대표배지를 설정해주세요',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansKR',
                  fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MyActivityHistory()),
                );
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xff333333)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
                  ),
                ),
              ),
              child:
                  buildText('나의 활동 내역', TextType.p14M, textColor: Colors.white),
            )
          ],
        );
      },
    ),
  );
}

// 박스의 그림자 효과
ShapeDecoration buildShadowDecoration() {
  return ShapeDecoration(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    shadows: const [
      BoxShadow(
        color: Color.fromARGB(10, 0, 0, 0),
        blurRadius: 24,
        offset: Offset(4, 4),
        spreadRadius: 0,
      )
    ],
  );
}

// 일반적으로 쓰이는 버튼
// 배경색 남색, 텍스트색 하얀색이 기본값
Widget buildButton(
  String text,
  Size size, {
  Color backgroundColor = const Color(0xFF001941),
  Color textColor = Colors.white,
  VoidCallback? onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(backgroundColor),
      minimumSize: MaterialStatePropertyAll(size),
      shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)))),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

enum TextType {
  /// H1 - 40px / 58px - Line Height / Bold 700
  h1,

  /// H2 - 28px / 42px - Line Height / Bold 700
  h2,

  /// H3 - 24px / 36px - Line Height / Bold 700
  h3,

  /// H4 - 20px / 30px - Line Height / Bold 700
  h4,

  /// H5 - 18px / 28px - Line Height / Bold 700
  h5,

  /// H6 - 16px / 24px - Line Height / Bold 700
  h6,

  /// P20 - 20px / 30px - Line Height / Medium 500
  p20M,

  /// P20 - 20px / 30px - Line Height / R 400
  p20R,

  /// P18 - 18px / 28px - Line Height / R 400
  p18R,

  /// P16 - 16px / Bold 700 / Line
  p16BLine,

  /// P16 - 16px / 24px - Line Height / Medium 500
  p16M,

  /// P16 - 16px / 24px - Line Height / R 400
  p16R,

  /// P14 - 14px / 20px - Line Height / Bold 700
  p14B,

  /// P14 - 14px / 20px - Line Height / Medium 500
  p14M,

  /// P14 - 14px / 20px - Line Height / R 400
  p14R,

  /// P12 - 12px / 18px - Line Height / Bold 700
  p12B,

  /// P12 - 12px / 18px - Line Height / Medium 500
  p12M,

  /// P12 - 12px / 18px - Line Height / R 400
  p12R,
}

Widget buildText(
  String desc,
  TextType textType, {
  TextAlign align = TextAlign.center,
  Color textColor = Colors.black,
  double screenSize = 0,
  isAutoSize = false,
  bool isEllipsis = false,
}) {
  TextStyle getTextStyle() {
    TextStyle thisStyle;
    String font = 'NotoSansKR';
    double autoSize = (screenSize / 390);

    double font14AutoSize = 14 * autoSize;
    if (font14AutoSize > 14) font14AutoSize = 14;
    double fontH4AutoSize = 20 * autoSize;
    if (fontH4AutoSize > 20) fontH4AutoSize = 20;
    double font18AutoSize = 18 * autoSize;
    if (font18AutoSize > 18) font18AutoSize = 18;

    switch (textType) {
      case TextType.h1:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 40,
            //height: 1.45,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.h2:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 28,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.h3:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 24,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.h4:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: isAutoSize ? fontH4AutoSize : 20,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.h5:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: isAutoSize ? font18AutoSize : 18,
            //height: 0.642857,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.h6:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 16,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.p20M:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 20,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w500);
        break;
      case TextType.p20R:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 20,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w400);
        break;
      case TextType.p18R:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: isAutoSize ? font18AutoSize : 18,
            //height: 0.642857,
            color: textColor,
            fontWeight: FontWeight.w400);
        break;
      case TextType.p16BLine:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline);
        break;
      case TextType.p16M:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 16,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w500);
        break;
      case TextType.p16R:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 16,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w400);
        break;
      case TextType.p14B:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 14,
            //height: 0.7,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.p14M:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: isAutoSize ? font14AutoSize : 14,
            //height: 0.7,
            color: textColor,
            fontWeight: FontWeight.w500);
        break;
      case TextType.p14R:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 14,
            //height: 0.7,
            color: textColor,
            fontWeight: FontWeight.w400);
        break;
      case TextType.p12B:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 12,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w700);
        break;
      case TextType.p12M:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 12,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w500);
        break;
      case TextType.p12R:
        thisStyle = TextStyle(
            fontFamily: font,
            fontSize: 12,
            //height: 0.66667,
            color: textColor,
            fontWeight: FontWeight.w400);
        break;
    }

    return thisStyle;
  }

  return AutoSizeText(
    desc,
    textAlign: align,
    style: getTextStyle(),
    overflow: isEllipsis ? TextOverflow.ellipsis : null,
  );
}

// class CustomText extends StatefulWidget {
//   final String desc;
//   final TextType textType;
//   TextAlign align;
//   Color textColor;

//   CustomText(
//       {Key? key,
//       required this.desc,
//       required this.textType,
//       this.align = TextAlign.center,
//       this.textColor = Colors.black});

//   @override
//   _CustomTextState createState() => _CustomTextState();
// }

// class _CustomTextState extends State<CustomText> {
//   @override
//   Widget build(BuildContext context) {
//     double screenSize = MediaQuery.of(context).size.width;

//   }
// }

class CustomDropdownMenu extends StatefulWidget {
  final List<String> menuItems;
  final String initialValue;
  final bool isEnable;
  Function(String)? onItemSelected;

  CustomDropdownMenu({
    super.key,
    required this.menuItems,
    required this.initialValue,
    required this.isEnable,
    this.onItemSelected,
  });

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenu();
}

class _CustomDropdownMenu extends State<CustomDropdownMenu> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      elevation: 0.2,
      color: Colors.white,
      position: PopupMenuPosition.under,
      enabled: widget.isEnable,
      onSelected: (String result) {
        setState(() {
          _selectedValue = result; // 사용자가 선택한 값을 저장
        });
        widget.onItemSelected!(result); // 콜백 함수 호출
      },
      itemBuilder: (BuildContext context) => widget.menuItems
          .map((String value) => PopupMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 16, fontFamily: 'NotoSansKR'),
                ),
                onTap: () {},
              ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildText(_selectedValue ?? widget.initialValue,
              TextType.h6), // 선택된 값 또는 초기 값 표시
          if (widget.isEnable)
            const Icon(Icons.keyboard_arrow_down), // 드롭다운 아이콘 표시
        ],
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  double appBarHeight; // AppBar의 높이를 동적으로 설정할 수 있는 매개변수 추가
  final VoidCallback? onHoverd;

  CustomAppBar({
    Key? key,
    this.appBarHeight = kToolbarHeight, // 기본값으로 kToolbarHeight 사용
    this.onHoverd,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  // preferredSize를 여기서 계산하지 않고, appBarHeight를 바탕으로 getter에서 반환
  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final String homeUrl = 'https://$domain/main/main.do';
  final String themaUrl = 'https://$domain/main/theme.do';
  final String areaUrl = 'https://$domain/main/area.do';
  final String traveUrl = 'https://$domain/main/cr_main.do?type=ai';
  final String tgprUrl = 'https://$domain/tgpr/tgpr_main.do';
  final String travInfoUrl = 'https://$domain/list/travelinfo.do?service=ms';

  final String myLocationUrl = 'https://$domain/mylocation/mylocation.do';

  /// lnb 여행지 url
  final String travelinfoDo = 'https://$domain/list/travelinfo.do?service=ms';

  /// lnb 여행기사 url
  final String travelinforem = 'https://$domain/list/travelinfo.do?service=rem';

  /// lnb 여행코스 url
  final String travelinfoCS = 'https://$domain/list/travelinfo.do?service=cs';

  /// lnb 축제 url
  final String traveWntyFstvlList =
      'https://$domain/kfes/list/wntyFstvlList.do';

  /// lnb 공연/행사 url
  final String travelInfoShow =
      'https://$domain/list/travelinfo.do?service=show';

  /// lnb 이벤트 url
  final String travelInfoEvent =
      'https://$domain/list/travelinfo.do?service=event';

  /// lnb 가볼래터 url
  final String travelInfoTrss =
      'https://$domain/list/travelinfo.do?service=trss';

  /// lnb 디지털관광주민증 url
  final String travelInfoDigt =
      'https://$domain/list/travelinfo.do?service=digt';

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    bool isMobile = screenSize < 1000; // 모바일 여부 확인
    bool isTablat = 600 < screenSize && screenSize < 1000;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(0.2), // Shadow color with some opacity
            spreadRadius:
                0, // Extent of the shadow spread; set to 0 for a sharp drop-off
            blurRadius: 10, // How much the shadow is blurred
            offset: const Offset(
                0, 2), // Horizontal and vertical offset of the shadow
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: widget.appBarHeight,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
            child: isMobile
                ? buildMobileTextButton(isTablat)
                : buildDescTopTextButton(screenSize)),
      ),
    );
  }

  Widget buildMobileTextButton(bool isTablat) {
    bool isCanPop = Navigator.of(context).canPop(); // 백 버튼 필요 여부 확인
    var mobilePadding =
        const EdgeInsets.symmetric(vertical: 14, horizontal: 24);
    var lnbPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 10);
    // 로고
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: Stack(
            children: [
              if (isCanPop) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 50,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
              Center(
                child: SizedBox(
                  height: 50,
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      redirectToUrl(homeUrl);
                    },
                    child: SizedBox(
                      width: 130,
                      child: Image.asset(
                        'assets/logo_Mobile.png',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // snb 영역
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: isTablat ? false : true,
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextButton(
                    btnText: '홈',
                    textType: TextType.p14M,
                    btnPadding: mobilePadding,
                    onPressed: () {
                      redirectToUrl(homeUrl);
                    },
                  ),
                  CustomTextButton(
                    btnText: '테마',
                    textType: TextType.p14M,
                    btnPadding: mobilePadding,
                    onPressed: () {
                      redirectToUrl(themaUrl);
                    },
                  ),
                  CustomTextButton(
                    btnText: '지역',
                    textType: TextType.p14M,
                    btnPadding: mobilePadding,
                    onPressed: () {
                      redirectToUrl(areaUrl);
                    },
                  ),
                  CustomTextButton(
                    btnText: '여행콕콕',
                    textType: TextType.p14M,
                    btnPadding: mobilePadding,
                    onPressed: () {
                      redirectToUrl(traveUrl);
                    },
                  ),
                  CustomTextButton(
                    btnText: '여행상품 홍보관',
                    textType: TextType.p14M,
                    btnPadding: mobilePadding,
                    onPressed: () {
                      redirectToUrl(tgprUrl);
                    },
                  ),
                  Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 2),
                      ),
                    ),
                    child: Center(
                      child: CustomTextButton(
                        btnText: '여행정보',
                        textType: TextType.p14B,
                        btnPadding: const EdgeInsets.all(0),
                        onPressed: () {
                          redirectToUrl(travInfoUrl);
                        },
                      ),
                    ),
                  ),
                  CustomTextButton(
                    btnText: '여행지도',
                    textType: TextType.p14M,
                    btnPadding: mobilePadding,
                    onPressed: () {
                      redirectToUrl(myLocationUrl);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // lnb 영역
        // Container(
        //   width: double.infinity,
        //   height: 50,
        //   padding: isTablat
        //       ? const EdgeInsets.symmetric(horizontal: 15)
        //       : const EdgeInsets.all(0),
        //   decoration: const BoxDecoration(color: Color(0xFFF4F6F8)),
        //   child: SingleChildScrollView(
        //     scrollDirection: Axis.horizontal,
        //     reverse: isTablat ? false : true,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.start,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         CustomTextButton(
        //           btnText: '여행지',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelinfoDo);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '여행기사',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelinforem);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '여행코스',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelinfoCS);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '축제',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(traveWntyFstvlList);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '공연/행사',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelInfoShow);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '이벤트',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelInfoEvent);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '가볼래-터',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelInfoTrss);
        //           },
        //         ),
        //         CustomTextButton(
        //           btnText: '디지털관광주민증',
        //           textType: TextType.p12M,
        //           btnPadding: lnbPadding,
        //           onPressed: () {
        //             redirectToUrl(travelInfoDigt);
        //           },
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.only(
        //               left: 0, top: 12, bottom: 12, right: 10),
        //           child: Container(
        //             padding:
        //                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //             decoration: ShapeDecoration(
        //               color: Colors.black,
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(20),
        //               ),
        //             ),
        //             child: Row(
        //               children: [
        //                 Image.asset('assets/badgeIcon.png'),
        //                 CustomTextButton(
        //                   btnText: '배지콕콕',
        //                   textType: TextType.p12M,
        //                   btnPadding: const EdgeInsets.all(0),
        //                   txtColor: Colors.white,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget buildDescTopTextButton(double scrrenSize) {
    bool isCanPop = Navigator.of(context).canPop(); // 백 버튼 필요 여부 확인
    var descTopPadding =
        const EdgeInsets.symmetric(horizontal: 27, vertical: 30);
    // 로고
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isCanPop) ...[
          SizedBox(
            width: 64,
            height: 90,
            child: IconButton(
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ] else
          const SizedBox(
            width: 64,
          ),
        SizedBox(
          width: 207,
          child: InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              redirectToUrl(homeUrl);
            },
            child: SizedBox(
              height: 36,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: scrrenSize * (222 / 1920),
        ),
        SizedBox(
          width: 850,
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextButton(
                btnText: '홈',
                textType: TextType.p20M,
                hoverType: TextType.h4,
                btnPadding: descTopPadding,
                onPressed: () {
                  redirectToUrl(homeUrl);
                },
                onHovered: () {
                  setState(() {
                    //widget.onHoverd!();
                  });
                },
              ),
              CustomTextButton(
                btnText: '테마',
                textType: TextType.p20M,
                hoverType: TextType.h4,
                btnPadding: descTopPadding,
                onPressed: () {
                  redirectToUrl(themaUrl);
                },
                onHovered: () {
                  setState(() {
                    //widget.onHoverd!();
                  });
                },
              ),
              CustomTextButton(
                btnText: '지역',
                textType: TextType.p20M,
                hoverType: TextType.h4,
                btnPadding: descTopPadding,
                onPressed: () {
                  redirectToUrl(areaUrl);
                },
                onHovered: () {
                  setState(() {
                    //widget.onHoverd!();
                  });
                },
              ),
              CustomTextButton(
                btnText: '여행콕콕',
                textType: TextType.p20M,
                hoverType: TextType.h4,
                btnPadding: descTopPadding,
                onPressed: () {
                  redirectToUrl(traveUrl);
                },
                onHovered: () {
                  setState(() {
                    //widget.onHoverd!();
                  });
                },
              ),
              CustomTextButton(
                btnText: '여행상품 홍보관',
                textType: TextType.p20M,
                hoverType: TextType.h4,
                btnPadding: descTopPadding,
                onPressed: () {
                  redirectToUrl(tgprUrl);
                },
                onHovered: () {
                  setState(() {
                    //widget.onHoverd!();
                  });
                },
              ),
              Padding(
                padding: descTopPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextButton(
                      btnText: '여행정보',
                      textType: TextType.h4,
                      btnPadding: EdgeInsets.zero,
                      onPressed: () {
                        redirectToUrl(travInfoUrl);
                      },
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ],
                ),
              ),
              CustomTextButton(
                btnText: '여행지도',
                textType: TextType.p20M,
                hoverType: TextType.h4,
                btnPadding: descTopPadding,
                onPressed: () {
                  redirectToUrl(myLocationUrl);
                },
                onHovered: () {
                  setState(() {
                    //widget.onHoverd!();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomTextButton extends StatefulWidget {
  final String btnText;
  final VoidCallback? onPressed;
  final VoidCallback? onHovered;
  final TextType textType;
  final TextType? hoverType;
  final Color? txtColor;
  final OutlinedBorder? border;
  final btnPadding;

  CustomTextButton({
    super.key,
    required this.btnText,
    this.onPressed,
    required this.textType,
    this.hoverType,
    required this.btnPadding,
    this.txtColor,
    this.border,
    this.onHovered,
  });

  @override
  _CustomTextButtonState createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(children: [
        TextButton(
            style: ButtonStyle(
              alignment: Alignment.center,
              padding: MaterialStatePropertyAll(widget.btnPadding),
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: widget.onPressed != null
                ? () {
                    widget.onPressed!();
                  }
                : null,
            onHover: (value) {
              setState(() {
                _isHovered = value;
                if (_isHovered && widget.onHovered != null) {
                  //print('TextButtonHover!');
                  widget.onHovered!();
                }
              });
            },
            child: _isHovered && widget.hoverType != null
                ? buildText(widget.btnText, widget.hoverType!,
                    textColor: widget.txtColor ?? Colors.black)
                : buildText(widget.btnText, widget.textType,
                    textColor: widget.txtColor ?? Colors.black)),
        if (_isHovered &&
            widget.hoverType != null) // 호버 상태일 때만 Container를 표시합니다.
          Positioned(
            top: 21,
            right: 18,
            child: Container(
              width: 5,
              height: 5,
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
      ]),
    );
  }
}

class CustomLnb extends StatefulWidget {
  CustomLnb();

  @override
  _CustomLnbState createState() => _CustomLnbState();
}

class _CustomLnbState extends State<CustomLnb> {
  /// lnb AI 콕콕 url
  final String ai = 'https://$domain/main/cr_main.do?type=ai';

  /// lnb 핫플 콕콕 url
  final String place = 'https://$domain/main/cr_main.do?type=place';

  /// lnb AI 콕콕 플래너 url
  final String best =
      'https://$domain/main/cr_main.do?type=abc&detailType=best';

  /// lnb 여행지 url
  final String travelinfoDo = 'https://$domain/list/travelinfo.do?service=ms';

  /// lnb 여행기사 url
  final String travelinforem = 'https://$domain/list/travelinfo.do?service=rem';

  /// lnb 여행코스 url
  final String travelinfoCS = 'https://$domain/list/travelinfo.do?service=cs';

  /// lnb 축제 url
  final String traveWntyFstvlList =
      'https://$domain/kfes/list/wntyFstvlList.do';

  /// lnb 공연/행사 url
  final String travelInfoShow =
      'https://$domain/list/travelinfo.do?service=show';

  /// lnb 이벤트 url
  final String travelInfoEvent =
      'https://$domain/list/travelinfo.do?service=event';

  /// lnb 가볼래터 url
  final String travelInfoTrss =
      'https://$domain/list/travelinfo.do?service=trss';

  /// lnb 디지털관광주민증 url
  final String travelInfoDigt =
      'https://$domain/list/travelinfo.do?service=digt';
  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    double leftPadding = screenSize * (222 / widthSize);
    return Container(
      //width: double.infinity,
      height: 276,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFFF3F4F7)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 64),
          SizedBox(
            width: leftPadding,
          ),
          const SizedBox(width: 207),
          SizedBox(
            width: 850,
            child: Row(
              children: [
                const SizedBox(
                  width: 270,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: 'AI콕콕',
                        onPressed: () {
                          redirectToUrl(travelinfoDo);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '핫플콕콕',
                        onPressed: () {
                          redirectToUrl(travelinfoDo);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: 'AI콕콕 플래너',
                        onPressed: () {
                          redirectToUrl(travelinfoDo);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 199),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '여행지',
                        onPressed: () {
                          redirectToUrl(travelinfoDo);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '여행기사',
                        onPressed: () {
                          redirectToUrl(travelinforem);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '여행코스',
                        onPressed: () {
                          redirectToUrl(travelinfoCS);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '축제',
                        onPressed: () {
                          redirectToUrl(traveWntyFstvlList);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '공연/행사',
                        onPressed: () {
                          redirectToUrl(travelInfoShow);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '이벤트',
                        onPressed: () {
                          redirectToUrl(travelInfoEvent);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '가볼래-터',
                        onPressed: () {
                          redirectToUrl(travelInfoTrss);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: CustomLnbTextButton(
                        btnText: '디지털관광주민증',
                        onPressed: () {
                          redirectToUrl(travelInfoDigt);
                        },
                      ),
                    ),
                    Container(
                      height: 28,
                      padding: const EdgeInsets.only(left: 12),
                      child: buildText('배지콕콕', TextType.p16BLine),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLnbTextButton extends StatefulWidget {
  final String btnText;
  final VoidCallback? onPressed;

  CustomLnbTextButton({super.key, required this.btnText, this.onPressed});

  @override
  _CustomLnbTextButtonState createState() => _CustomLnbTextButtonState();
}

class _CustomLnbTextButtonState extends State<CustomLnbTextButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: widget.onPressed,
        onHover: (value) {
          setState(() {
            _isHovered = value;
          });
        },
        child: _isHovered
            ? buildText(widget.btnText, TextType.p16BLine)
            : buildText(widget.btnText, TextType.p16M,
                textColor: const Color(0xFF5B5B5B)));
  }
}

Widget buildPrivacyCancelCard(bool isMobile, BuildContext context) {
  return Container(
    width: double.infinity,
    height: isMobile ? 104 : 117,
    padding: EdgeInsets.all(isMobile ? 8 : 16),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          '개인정보 수집 이용 동의 취소 시,',
          TextType.p14R,
          textColor: Colors.black,
        ),
        buildText(
          '배지콕콕 랭킹전 및 경품 이벤트 참여가 제한됩니다.',
          TextType.p14R,
          textColor: Colors.black,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
            onPressed: () {
              showUserInfoAgreementCancelPopup(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D7D7D), // 버튼 배경색
                minimumSize: const Size(double.infinity, 39), // 버튼 크기
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // 모서리 둥글기
                ),
                padding: const EdgeInsets.all(8)),
            child: buildText(
              '개인정보 수집 및 이용 동의 취소',
              TextType.p16M,
              textColor: Colors.white,
            )),
      ],
    ),
  );
}

void redirectToUrl(String url) {
  js.context.callMethod('open', [url, '_self']);
}
