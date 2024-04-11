import 'package:flutter/material.dart';
import '../common_widgets.dart';

// // 안쓰는 부분
// Widget buildTitleBanner() {
//   return Container(
//     width: double.infinity,
//     height: 230,
//     padding: const EdgeInsets.all(16),
//     decoration: const BoxDecoration(color: Color(0xFFEBEBEB)),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text(
//           '대한민국 구석구석 퀘스트 서비스',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 12,
//             fontFamily: 'NotoSansKR',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const Text(
//           '여행도감',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 40,
//             fontFamily: 'NotoSansKR',
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           '여행을 즐기는 또 다른 방법 “여행도감”을 소개합니다.\n대한민국 구석구석 내의 다양한 도전 과제에 참여해보세요.\n배지를 수집하여 대한민국 관광 마스터가 되어보세요! ',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 12,
//             fontFamily: 'NotoSansKR',
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         const SizedBox(height: 24),
//         Container(
//           child: ElevatedButton(
//             onPressed: () {
//               // 버튼 클릭 시 수행할 동작
//             },
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.black,
//               backgroundColor: Colors.white, // 버튼 텍스트 색상
//               side: const BorderSide(
//                   width: 1, color: Color(0xFFBEC9A6)), // 테두리 스타일
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16), // 둥근 모서리
//               ),
//             ),
//             child:
//                 buildText('퀘스트 서비스 이용 방법 >', textColor: Colors.black, size: 12),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//Widget buildEventAcceptCard(bool isMobile, BuildContext context) {
//   return Container(
//     width: double.infinity,
//     height: 145,
//     padding: EdgeInsets.all(isMobile ? 8 : 16),
//     clipBehavior: Clip.antiAlias,
//     decoration: ShapeDecoration(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         side: const BorderSide(width: 1, color: Color(0xFFEEEEEE)),
//         borderRadius: BorderRadius.circular(8),
//       ),
//     ),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         buildText('잠깐! 현재 진행중인 이벤트가 있어요', isMobile ? TextType.h5 : TextType.h4),
//         isMobile ? const SizedBox(height: 12) : const SizedBox(height: 8),
//         if (isMobile) ...[
//           buildText(
//             '이벤트 참여에 동의하시면 다양한 경품 이벤트에', 
//             textColor: Colors.black,
//             size: 14,
//             weight: FontWeight.w400,
//           ),
//           buildText(
//             '참여하실 수 있어요',
//             textColor: Colors.black,
//             size: 14,
//             weight: FontWeight.w400,
//           ),
//           const SizedBox(height: 12),
//         ] else ...[
//           buildText(
//             '이벤트 참여에 동의하시면 다양한 경품 이벤트에 참여하실 수 있어요',
//             textColor: Colors.black,
//             size: isMobile ? 14 : 15,
//             weight: FontWeight.w400,
//           ),
//           const SizedBox(height: 16),
//         ],
//         ElevatedButton(
//             onPressed: () {
//               // 버튼 클릭 시 수행할 작업 추가
//               showjoinEventAcceptPopup(context);
//             },
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF001940), // 버튼 배경색
//                 minimumSize: const Size(double.infinity, 39), // 버튼 크기
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5), // 모서리 둥글기
//                 ),
//                 padding: const EdgeInsets.all(8)),
//             child: buildText(
//               '이벤트 참여 동의',
//               textColor: Colors.white,
//               size: 16,
//             )),
//       ],
//     ),
//   );
// }

// int? selectedUserId; // 선택된 사용자의 ID를 저장할 변수
  // Widget buildMainBadgeCard() {
  //   return Container(
  //     width: 892,
  //     height: 130,
  //     padding: const EdgeInsets.only(
  //       top: 24,
  //       left: 16,
  //       right: 16,
  //       bottom: 16,
  //     ),
  //     clipBehavior: Clip.antiAlias,
  //     decoration: ShapeDecoration(
  //       color: const Color(0xFFEDEFFB),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       shadows: const [
  //         BoxShadow(
  //           color: Color(0x0F000000),
  //           blurRadius: 24,
  //           offset: Offset(4, 4),
  //           spreadRadius: 0,
  //         )
  //       ],
  //     ),
  //     child: Consumer2<QuestProvider, BadgeProvider>(
  //         builder: (context, questProvider, badgeProvider, child) {
  //       return Column(
  //         mainAxisSize: MainAxisSize.min,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Consumer2<QuestProvider, BadgeProvider>(
  //               builder: (context, questProvider, badgeProvider, child) {
  //             return Container(
  //               width: double.infinity,
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   buildMainBadgeImage(context),
  //                   const SizedBox(width: 24),
  //                   Expanded(
  //                     child: Container(
  //                         width: 405,
  //                         child: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             if (isLogin)
  //                               buildLoginText(context)
  //                             else
  //                               buildNonLoginText(false)
  //                           ],
  //                         )),
  //                   ),
  //                   const SizedBox(width: 24),
  //                   if (isLogin) ...[
  //                     Container(
  //                       width: 320,
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           ElevatedButton(
  //                             onPressed: () {
  //                               buildRankPopup(context);
  //                               // '랭킹보기' 버튼 클릭 시 실행할 코드
  //                               // Navigator.push(
  //                               //     context,
  //                               //     MaterialPageRoute(
  //                               //         builder: (context) =>
  //                               //             RankingListPage()));
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor:
  //                                   const Color(0xFF001940), // 버튼 배경색
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(5),
  //                               ),
  //                               padding: const EdgeInsets.all(8),
  //                               fixedSize: const Size(320, 39),
  //                               elevation: 0, // 그림자 제거 // 버튼 크기
  //                             ),
  //                             child: buildText('랭킹보기',
  //                                 textColor: Colors.white,
  //                                 size: 16,
  //                                 align: TextAlign.center),
  //                           ),
  //                           const SizedBox(height: 8),
  //                           ElevatedButton(
  //                             onPressed: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) =>
  //                                         MyBadgeCollections()),
  //                               );
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: Color(0xffFFFFFF), // 버튼 배경색
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(5),
  //                               ),
  //                               padding: const EdgeInsets.all(8),
  //                               fixedSize: const Size(320, 39),
  //                               elevation: 0, // 그림자 제거 // 버튼 크기
  //                             ),
  //                             child: buildText('배지도감',
  //                                 size: 16, align: TextAlign.center),
  //                           ),
  //                         ],
  //                       ),
  //                     )
  //                   ] else ...[
  //                     buildButton(
  //                       '로그인 후 활동배지 획득하기',
  //                       const Size(320, 39),
  //                       onPressed: () {
  //                         showNonLoginAlertDialog(context);
  //                         //showjoinEventAcceptPopup(context);
  //                         // 계정 테스트를 위해 만든 기능.
  //                         // showDialog(
  //                         //   context: context,
  //                         //   builder: (BuildContext context) {
  //                         //     return AlertDialog(
  //                         //       title: Text('로그인 아이디를 선택해주세요'),
  //                         //       content: Container(
  //                         //         width: double.maxFinite,
  //                         //         child: ListView.builder(
  //                         //           shrinkWrap: true,
  //                         //           itemCount: testUserList.length,
  //                         //           itemBuilder:
  //                         //               (BuildContext context, int index) {
  //                         //             bool isSelected =
  //                         //                 testUserList[index].id ==
  //                         //                     selectedUserId;
  //                         //             return InkWell(
  //                         //               onTap: () async {
  //                         //                 userSession = UserSession(
  //                         //                     sessionId: testUserList[index]
  //                         //                         .id
  //                         //                         .toString(),
  //                         //                     snsId: testUserList[index].snsId);

  //                         //                 setState(() {
  //                         //                   selectedUserId = isSelected
  //                         //                       ? null
  //                         //                       : testUserList[index].id;
  //                         //                 });

  //                         //                 isLogin = true;
  //                         //                 await Future.wait([
  //                         //                   Provider.of<UserInfoProvider>(
  //                         //                           context,
  //                         //                           listen: false)
  //                         //                       .refreshData(),
  //                         //                   Provider.of<UserPrivacyInfoProvider>(
  //                         //                           context,
  //                         //                           listen: false)
  //                         //                       .refreshData(),
  //                         //                   Provider.of<UserHistoryProvider>(
  //                         //                           context,
  //                         //                           listen: false)
  //                         //                       .refreshData(),
  //                         //                   Provider.of<RankingProvider>(
  //                         //                           context,
  //                         //                           listen: false)
  //                         //                       .refreshData(),
  //                         //                   questProvider.refreshQuests(),
  //                         //                   badgeProvider.refreshBadges(),
  //                         //                 ]);

  //                         //                 Navigator.pop(context);
  //                         //               },
  //                         //               child: Container(
  //                         //                 color: isSelected
  //                         //                     ? Colors.grey.shade300
  //                         //                     : null, // 선택된 항목은 음영 처리
  //                         //                 child: ListTile(
  //                         //                   title: Text(
  //                         //                       'User ${testUserList[index].id}'),
  //                         //                 ),
  //                         //               ),
  //                         //             );
  //                         //           },
  //                         //         ),
  //                         //       ),
  //                         //       actions: <Widget>[
  //                         //         TextButton(
  //                         //           child: Text('닫기'),
  //                         //           onPressed: () {
  //                         //             Navigator.of(context).pop(); // 다이얼로그 닫기
  //                         //           },
  //                         //         ),
  //                         //       ],
  //                         //     );
  //                         //   },
  //                         // );
  //                       },
  //                     ),
  //                   ]
  //                 ],
  //               ),
  //             );
  //           })
  //         ],
  //       );
  //     }),
  //   );
  // }

  // int? selectedUserId; // 선택된 사용자의 ID를 저장할 변수
  // Widget buildMainBadgeCard() {
  //   return Container(
  //     width: 892,
  //     padding: const EdgeInsets.all(16),
  //     clipBehavior: Clip.antiAlias,
  //     decoration: ShapeDecoration(
  //       color: const Color(0xFFEDEFFB),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       shadows: const [
  //         BoxShadow(
  //           color: Color(0x0F000000),
  //           blurRadius: 24,
  //           offset: Offset(4, 4),
  //           spreadRadius: 0,
  //         )
  //       ],
  //     ),
  //     child: Consumer2<QuestProvider, BadgeProvider>(
  //       builder: (context, questProvider, badgeProvider, child) {
  //         return Column(
  //             //mainAxisSize: MainAxisSize.min,
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               Container(
  //                 width: double.infinity,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     buildMainBadgeImage(context),
  //                     const SizedBox(width: 17),
  //                     if (isLogin)
  //                       buildLoginText(context)
  //                     else
  //                       buildNonLoginText(true),
  //                   ],
  //                 ),
  //               ),
  //               if (isLogin) ...[
  //                 Container(
  //                   width: double.infinity,
  //                   height: 39,
  //                   clipBehavior: Clip.antiAlias,
  //                   decoration: const BoxDecoration(),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: () {
  //                             buildRankPopup(context);
  //                             // '랭킹보기' 버튼 클릭 시 실행할 코드
  //                             // Navigator.push(
  //                             //     context,
  //                             //     MaterialPageRoute(
  //                             //         builder: (context) => RankingListPage()));
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor:
  //                                 const Color(0xFF001940), // 버튼 배경색
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(5),
  //                             ),
  //                             padding: const EdgeInsets.all(8),
  //                             fixedSize:
  //                                 const Size(double.infinity, 39), // 버튼 크기
  //                           ),
  //                           child: buildText('랭킹보기',
  //                               textColor: Colors.white,
  //                               size: 16,
  //                               align: TextAlign.center),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed: () {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) => MyBadgeCollections()),
  //                             );
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.white, // 버튼 배경색
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(5),
  //                             ),
  //                             padding: const EdgeInsets.all(8),
  //                             fixedSize:
  //                                 const Size(double.infinity, 39), // 버튼 크기
  //                           ),
  //                           child: buildText('배지도감',
  //                               size: 16, align: TextAlign.center),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //               ] else ...[
  //                 buildButton(
  //                   '로그인 후 활동배지 획득하기',
  //                   const Size(double.infinity, 39),
  //                   onPressed: () {
  //                     showNonLoginAlertDialog(context);
  //                     // 계정 테스트를 위해 만든 기능.
  //                     // showDialog(
  //                     //   context: context,
  //                     //   builder: (BuildContext context) {
  //                     //     return AlertDialog(
  //                     //       title: const Text('로그인 아이디를 선택해주세요'),
  //                     //       content: Container(
  //                     //         width: double.maxFinite,
  //                     //         child: ListView.builder(
  //                     //           shrinkWrap: true,
  //                     //           itemCount: testUserList.length,
  //                     //           itemBuilder: (BuildContext context, int index) {
  //                     //             bool isSelected =
  //                     //                 testUserList[index].id == selectedUserId;
  //                     //             return InkWell(
  //                     //               onTap: () async {
  //                     //                 userSession = UserSession(
  //                     //                     sessionId:
  //                     //                         testUserList[index].id.toString(),
  //                     //                     snsId: testUserList[index].snsId);

  //                     //                 setState(() {
  //                     //                   selectedUserId = isSelected
  //                     //                       ? null
  //                     //                       : testUserList[index].id;
  //                     //                 });

  //                     //                 isLogin = true;
  //                     //                 await Future.wait([
  //                     //                   Provider.of<UserInfoProvider>(context,
  //                     //                           listen: false)
  //                     //                       .refreshData(),
  //                     //                   Provider.of<UserPrivacyInfoProvider>(
  //                     //                           context,
  //                     //                           listen: false)
  //                     //                       .refreshData(),
  //                     //                   Provider.of<UserHistoryProvider>(
  //                     //                           context,
  //                     //                           listen: false)
  //                     //                       .refreshData(),
  //                     //                   Provider.of<RankingProvider>(context,
  //                     //                           listen: false)
  //                     //                       .refreshData(),
  //                     //                   questProvider.refreshQuests(),
  //                     //                   badgeProvider.refreshBadges(),
  //                     //                 ]);

  //                     //                 Navigator.pop(context);
  //                     //               },
  //                     //               child: Container(
  //                     //                 color: isSelected
  //                     //                     ? Colors.grey.shade300
  //                     //                     : null, // 선택된 항목은 음영 처리
  //                     //                 child: ListTile(
  //                     //                   title: Text(
  //                     //                       'User ${testUserList[index].id}'),
  //                     //                 ),
  //                     //               ),
  //                     //             );
  //                     //           },
  //                     //         ),
  //                     //       ),
  //                     //       actions: <Widget>[
  //                     //         TextButton(
  //                     //           child: const Text('닫기'),
  //                     //           onPressed: () {
  //                     //             Navigator.of(context).pop(); // 다이얼로그 닫기
  //                     //           },
  //                     //         ),
  //                     //       ],
  //                     //     );
  //                     //   },
  //                     // );
  //                   },
  //                 ),
  //               ],
  //             ]);
  //       },
  //     ),
  //   );
  // }

  // List<Quest> filterQuests(List<Quest> quests) {
//   List<Quest> filterQuest = List.from(quests);

//   for (var quest in quests) {
//     // 배지를 수령 완료한 퀘스트일때, 다음 등급의 퀘스트가 존재 하면 리스트에서 삭제
//     if (quest.progressType == ProgressType.receive) {
//       if (quest.questDetails.nextQuestId != null) {
//         filterQuest.remove(quest);
//       }
//     } else {
//       // 배지 수령이 안된 퀘스트들은 다음 등급의 퀘스트들이 노출되면 안된다.

//       // 다음 등급의 퀘스트가 있을 때
//       if (quest.questDetails.nextQuestId != null) {
//         // 다음 등급의 퀘스트 id 저장
//         String? nId = quest.questDetails.nextQuestId;

//         while (nId != null) {
//           // nid로 다음 등급의 퀘스트 찾아서 삭제
//           var nQuest =
//               quests.singleWhereOrNull((e) => e.questDetails.questId == nId);
//           filterQuest.remove(nQuest);

//           // 또 다음 등급의 퀘스트가 있는지 검색
//           if (nQuest?.questDetails.nextQuestId == null) {
//             break;
//           }

//           nId = nQuest?.questDetails.nextQuestId;
//         }
//       }
//     }
//   }

//   filterQuest.sort(
//       (a, b) => a.questDetails.orderIndex.compareTo(b.questDetails.orderIndex));
//   return filterQuest;
// }
