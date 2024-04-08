// import 'package:flutter/material.dart';
// import 'package:visitkorea/model/userInfo.dart';
// import '../common_widgets.dart';
// import 'package:provider/provider.dart';
// import '../jsonLoader.dart';
// import 'package:flutter/cupertino.dart';

// OverlayEntry? overlayEntry;

// enum ConsentOption { agree, disagree }

// void showEventAcceptPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: true, // 다이얼로그 바깥을 탭하면 닫히도록 설정
//     builder: (BuildContext context) {
//       return EventAcceptPopup();
//     },
//   );
// }

// // 이벤트 동의 팝업
// class EventAcceptPopup extends StatefulWidget {
//   EventAcceptPopup({
//     Key? key,
//   });
//   @override
//   _EventAcceptPopup createState() => _EventAcceptPopup();
// }

// class _EventAcceptPopup extends State<EventAcceptPopup> {
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   ConsentOption? _selectedOption = ConsentOption.agree;

//   // 입력된 이름이 숫자인지 확인하는 함수
//   bool isNameValid(String name) {
//     return RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name);
//   }

//   // 입력된 전화번호가 숫자인지 확인하는 함수
//   bool isPhoneNumberValid(String phoneNumber) {
//     return RegExp(r'^[0-9]+$').hasMatch(phoneNumber);
//   }

//   void showAlert(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: Text('이벤트 동의'),
//           content: SingleChildScrollView(
//             // 내용이 길어질 수 있으므로 SingleChildScrollView 사용
//             child: ListBody(
//               // ListBody를 사용하여 자식들이 수직으로 배치되도록 함
//               children: <Widget>[
//                 Text(message),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text(
//                 '확인',
//                 style: TextStyle(color: Colors.blue),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(); // 대화상자 닫기
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void pressedOk() {
//     String nameText = nameController.text;
//     String phoneNumText = phoneController.text;

//     bool isName = isNameValid(nameText);
//     bool isPhoneNum = isPhoneNumberValid(phoneNumText);
//     bool isAgree = _selectedOption == ConsentOption.agree;

//     if (isName && isPhoneNum && isAgree) {
//       UserPrivacyInfoProvider provider = Provider.of(context, listen: false);
//       provider.updateData(
//           UserPrivacyInfo(
//               snsQuestInfoId: provider.userPrivacyInfo.snsQuestInfoId,
//               isEventAgree: isAgree,
//               isPrivacyAgree: isAgree,
//               name: nameText,
//               phoneNumber: phoneNumText,
//               isExposeRank: provider.userPrivacyInfo.isExposeRank), () {
//         showAlert('이벤트 참여 완료되었습니다.');
//       });
//       Navigator.of(context).pop(); // 대화상자 닫기
//       showAlert('이벤트 참여 완료되었습니다.');
//     } else {
//       if (isAgree) {
//         showAlert('정확한 정보를 입력해주세요.');
//       } else {
//         Navigator.of(context).pop(); // 대화상자 닫기
//       }
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width > 650 ? false : true;
//     double pWidth = isMobile ? 360 : 600;
//     double pHeight = isMobile ? 1062 : 902;
//     double spanSizedBoxValue = isMobile ? 16 : 17;

//     // 라디오 버튼을 포함하는 위젯 생성
//     Widget createRadioListTile(ConsentOption value, String title) {
//       return ListTile(
//         contentPadding: EdgeInsets.zero, // 이 부분을 추가하여 ListTile의 패딩을 제거
//         title: Text(title),
//         leading: Radio<ConsentOption>(
//           value: value,
//           groupValue: _selectedOption,
//           onChanged: (ConsentOption? newValue) {
//             setState(() {
//               _selectedOption = newValue;
//             });
//           },
//           activeColor: const Color(0xFF228FFF),
//         ),
//       );
//     }

//     // Row 또는 Column을 사용하여 라디오 버튼들을 배치
//     Widget radioGroup = isMobile
//         ? Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               createRadioListTile(ConsentOption.agree, '동의합니다'),
//               createRadioListTile(ConsentOption.disagree, '동의하지 않습니다'),
//             ],
//           )
//         : Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Expanded(
//                   child: createRadioListTile(ConsentOption.agree, '동의합니다')),
//               Expanded(
//                   child:
//                       createRadioListTile(ConsentOption.disagree, '동의하지 않습니다')),
//             ],
//           );

//     /// 입력 텍스트 필드
//     Widget buildTextField(bool isMobile) {
//       return Column(children: [
//         Container(
//             width: isMobile ? 326 : 568,
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//             clipBehavior: Clip.antiAlias,
//             decoration: const ShapeDecoration(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 side: BorderSide(width: 1, color: Color(0xFFDCDFE6)),
//               ),
//             ),
//             child: TextFormField(
//               controller: nameController,
//               scrollPadding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom),
//               decoration: const InputDecoration(
//                 hintText: '이름(필수)',
//                 hintStyle: TextStyle(
//                     color: Color(0xFF999999),
//                     fontSize: 15,
//                     fontWeight: FontWeight.w400),
//                 border: InputBorder.none,
//               ),
//               textAlign: TextAlign.center,
//             )),
//         const SizedBox(height: 4),
//         Container(
//             width: isMobile ? 326 : 568,
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//             clipBehavior: Clip.antiAlias,
//             decoration: const ShapeDecoration(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 side: BorderSide(width: 1, color: Color(0xFFDCDFE6)),
//               ),
//             ),
//             child: TextFormField(
//               controller: phoneController,
//               scrollPadding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom),
//               decoration: const InputDecoration(
//                 hintText: '휴대전화번호(필수)-를 빼고 입력해주세요',
//                 hintStyle: TextStyle(
//                     color: Color(0xFF999999),
//                     fontSize: 15,
//                     fontWeight: FontWeight.w400),
//                 border: InputBorder.none, // 이 부분을 추가하여 밑줄을 제거합니다.
//               ),
//               textAlign: TextAlign.center,
//             )),
//         SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//       ]);
//     }

//     return Stack(
//       children: [
//         // 반투명 배경 추가
//         GestureDetector(
//           onTap: () {
//             Navigator.of(context).pop(); // 대화상자 닫기
//           },
//           child: Container(
//             color: Colors.black.withOpacity(0.5),
//           ),
//         ),
//         Center(
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: pWidth,
//               height: pHeight,
//               padding: const EdgeInsets.all(16),
//               clipBehavior: Clip.antiAlias,
//               decoration: ShapeDecoration(
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 32,
//                     child: buildText('이벤트 참여하기', TextType.h4),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: double.infinity,
//                     decoration: const ShapeDecoration(
//                       shape: RoundedRectangleBorder(
//                         side: BorderSide(
//                           width: 1,
//                           strokeAlign: BorderSide.strokeAlignCenter,
//                           color: Color(0xFFDDDDDD),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: spanSizedBoxValue),
//                   Expanded(
//                     child: Container(
//                       width: pWidth,
//                       child: SingleChildScrollView(
//                         // 하단 패딩 추가
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               width: double.infinity,
//                               child: buildText(
//                                   '개인정보 수집 이용 동의 및 처리 위탁 고지', TextType.p16R,
//                                   textColor: const Color(0xFF333333),
//                                   align: TextAlign.left),
//                             ),
//                             SizedBox(height: spanSizedBoxValue),
//                             buildText('개인정보수집 이용 동의', TextType.h6),
//                             const SizedBox(height: 8),
//                             buildAcceptTabe(isMobile),
//                             SizedBox(height: spanSizedBoxValue),
//                             buildPopupInfoText(isMobile),
//                             SizedBox(height: spanSizedBoxValue),
//                             radioGroup,
//                             SizedBox(height: spanSizedBoxValue),
//                             Image.asset('assets/PopupLine.png'),
//                             SizedBox(height: spanSizedBoxValue),
//                             buildText('개인정보처리위탁 고지', TextType.h6),
//                             buildText('*필수 위탁 고지', TextType.p14R,
//                                 textColor: Colors.red),
//                             const SizedBox(height: 8),
//                             buildPrivacyNotices(isMobile),
//                             SizedBox(height: spanSizedBoxValue),
//                             buildText('참여정보', TextType.h6),
//                             const SizedBox(height: 8),
//                             buildTextField(isMobile),
//                             SizedBox(height: spanSizedBoxValue),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   buildPopupButton(context)
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildPopupButton(BuildContext context) {
//     return Center(
//       child: Container(
//         width: 326,
//         height: 42,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // 대화상자 닫기
//                 },
//                 style: const ButtonStyle(
//                   backgroundColor: MaterialStatePropertyAll(Color(0xFFEEEEEE)),
//                   fixedSize: MaterialStatePropertyAll(Size(155, 42)),
//                   shape: MaterialStatePropertyAll(
//                     RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
//                     ),
//                   ),
//                 ),
//                 child: buildText('취소', TextType.p16R)),
//             const SizedBox(width: 16),
//             ElevatedButton(
//                 onPressed: () async {
//                   pressedOk();
//                 },
//                 style: const ButtonStyle(
//                   backgroundColor: MaterialStatePropertyAll(Color(0xFF001941)),
//                   fixedSize: MaterialStatePropertyAll(Size(155, 42)),
//                   shape: MaterialStatePropertyAll(
//                     RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.all(Radius.circular(3)), // 모서리를 사각형으로 설정
//                     ),
//                   ),
//                 ),
//                 child: buildText('확인', TextType.p16R, textColor: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 개인정보수집 이용 동의 표
// Widget buildAcceptTabe(bool isMobile) {
//   var deco = const BoxDecoration(
//     color: Color(0xFFF1F1F1),
//     border: Border(
//       left: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
//       top: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
//       right: BorderSide(color: Color(0xFFDDDDDD)),
//       bottom: BorderSide(color: Color(0xFFDDDDDD)),
//     ),
//   );

//   return Table(
//     border: TableBorder.all(), // 테이블 경계선을 설정합니다.
//     columnWidths: <int, TableColumnWidth>{
//       0: const FixedColumnWidth(110),
//       1: FixedColumnWidth(isMobile ? 216 : 458),
//     },
//     children: [
//       TableRow(
//         // 첫 번째 행
//         children: [
//           Container(
//             height: 40,
//             padding: const EdgeInsets.all(8.0),
//             clipBehavior: Clip.antiAlias,
//             decoration: deco,
//             child: buildText('수집항목', TextType.p14B, align: TextAlign.left),
//           ),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('이름, 휴대전화번호',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       TableRow(
//         // 두 번째 행
//         children: [
//           Container(
//             height: isMobile ? 56 : 40,
//             padding: const EdgeInsets.all(8.0),
//             decoration: deco,
//             child: buildText('수집 및 이용목적',
//                 size: 14, weight: FontWeight.w700, align: TextAlign.left),
//           ),
//           Container(
//             height: isMobile ? 56 : 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('이벤트 참여 시 본인 확인, 이벤트 당첨 시 당첨 내역 발송',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       TableRow(
//         // 두 번째 행
//         children: [
//           Container(
//             height: isMobile ? 64 : 40,
//             padding: const EdgeInsets.all(8.0),
//             decoration: deco,
//             child: buildText('보유 및 이용기간',
//                 size: 14, weight: FontWeight.w700, align: TextAlign.left),
//           ),
//           Container(
//             height: isMobile ? 64 : 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('신청일로부터 3개월 까지 보유 후 파기',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       // 더 많은 행을 추가할 수 있습니다.
//     ],
//   );
// }

// Widget buildPopupInfoText(bool isMobile) {
//   return Container(
//     width: isMobile ? 326 : 600,
//     height: isMobile ? 140 : 100,
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//     decoration: const BoxDecoration(color: Color(0xFFF1F1F1)),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text.rich(
//           TextSpan(
//             children: [
//               const TextSpan(
//                 text: '•  귀하께서는 본 동의를 거절하실 수 있습니다.\n',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                   fontFamily: 'NotoSansKR',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               TextSpan(
//                 text: isMobile
//                     ? '   거절하신 경우 퀘스트 참여는 가능하나 경품 이벤트\n   추첨 대상에서 제외됩니다.'
//                     : '   거절하신 경우 퀘스트 참여는 가능하나 경품 이벤트 추첨 대상에서 제외됩니다.',
//                 style: const TextStyle(
//                   color: Color(0xFFFF2525),
//                   fontSize: 14,
//                   fontFamily: 'NotoSansKR',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         buildText('•  참여를 거절하신 경우 도전과제 페이지 내에서 이벤트 참여를 재신청하실 수 있습니다.',
//             size: 14, weight: FontWeight.w400, align: TextAlign.left)
//       ],
//     ),
//   );
// }

// Widget buildPrivacyNotices(bool isMobile) {
//   var deco = const BoxDecoration(
//     color: Color(0xFFF1F1F1),
//     border: Border(
//       left: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
//       top: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
//       right: BorderSide(color: Color(0xFFDDDDDD)),
//       bottom: BorderSide(color: Color(0xFFDDDDDD)),
//     ),
//   );

//   return Table(
//     border: TableBorder.all(), // 테이블 경계선을 설정합니다.
//     columnWidths: <int, TableColumnWidth>{
//       0: const FixedColumnWidth(110),
//       1: FixedColumnWidth(isMobile ? 216 : 458),
//     },
//     children: [
//       TableRow(
//         // 첫 번째 행
//         children: [
//           Container(
//             height: 40,
//             padding: const EdgeInsets.all(8.0),
//             clipBehavior: Clip.antiAlias,
//             decoration: deco,
//             child: buildText('수집항목',
//                 size: 14, weight: FontWeight.w700, align: TextAlign.left),
//           ),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('이름, 휴대전화번호',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       TableRow(
//         // 두 번째 행
//         children: [
//           Container(
//             height: isMobile ? 56 : 40,
//             padding: const EdgeInsets.all(8.0),
//             decoration: deco,
//             child: buildText('위탁업무 내용',
//                 size: 14, weight: FontWeight.w700, align: TextAlign.left),
//           ),
//           Container(
//             height: isMobile ? 56 : 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('시스템 운영, 시스템 관리, 시스템 유지보수 등',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       TableRow(
//         // 두 번째 행
//         children: [
//           Container(
//             height: 40,
//             padding: const EdgeInsets.all(8.0),
//             decoration: deco,
//             child: buildText('수탁업체',
//                 size: 14, weight: FontWeight.w700, align: TextAlign.left),
//           ),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('위탁업체',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       TableRow(
//         // 두 번째 행
//         children: [
//           Container(
//             height: isMobile ? 64 : 40,
//             padding: const EdgeInsets.all(8.0),
//             decoration: deco,
//             child: buildText('위탁업무 내용',
//                 size: 14, weight: FontWeight.w700, align: TextAlign.left),
//           ),
//           Container(
//             height: isMobile ? 64 : 40,
//             padding: const EdgeInsets.all(8.0),
//             child: buildText('시스템 운영, 시스템 관리, 시스템 유지보수 등',
//                 size: 14, weight: FontWeight.w400, align: TextAlign.left),
//           ),
//         ],
//       ),
//       // 더 많은 행을 추가할 수 있습니다.
//     ],
//   );
// }
