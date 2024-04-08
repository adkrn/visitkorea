import 'package:flutter/material.dart';
import 'package:visitkorea/questListPage/questListPage.dart';
import 'model/quest.dart';
import 'jsonLoader.dart';
import 'package:provider/provider.dart';
import 'model/userSession.dart';
import 'model/testUserInfo.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;

// 임시 테스트 변수
bool isEventAccept = false; // 이벤트 참여동의 여부
UserSession? userSession;
Badge_completed? mainBadge;
List<TestUser> testUserList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과의 바인딩을 초기화합니다.

  await fetchSession();


  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => QuestProvider(), lazy: false),
      ChangeNotifierProvider(create: (context) => BadgeProvider(), lazy: false),
      ChangeNotifierProvider(
          create: (context) => RankingProvider(), lazy: false),
      ChangeNotifierProvider(
          create: (context) => UserHistoryProvider(), lazy: false),
      ChangeNotifierProvider(
          create: (context) => UserInfoProvider(), lazy: false),
      ChangeNotifierProvider(
          create: (context) => UserPrivacyInfoProvider(), lazy: false),
      ChangeNotifierProvider(
          create: (context) => EventBannerProvider(), lazy: false),
    ], child: MyApp()),
  );

}

Future<void> loadFonts() async {
  await FontLoader('NotoSansKR').load();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {

  Future<void> _loadResources(BuildContext context) async {
    await Future.wait([
      loadFonts(),
      // 다른 초기화 작업들을 여기에 추가하세요. 예를 들어:
      // fetchTestUserList(),
    ]);
    // 모든 리소스 로딩이 완료되면 QuestListPage로 이동합니다.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => QuestListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadResources(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 로딩 인디케이터를 표시합니다.
      ),
    );
  }
}
