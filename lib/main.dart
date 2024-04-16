import 'package:flutter/material.dart';
import 'package:visitkorea/questListPage/questListPage.dart';
import 'model/quest.dart';
import 'jsonLoader.dart';
import 'package:provider/provider.dart';
import 'model/userSession.dart';
import 'model/testUserInfo.dart';
import 'package:flutter/services.dart';

// 임시 테스트 변수
bool isEventAccept = false; // 이벤트 참여동의 여부
UserSession? userSession;
Badge_completed? mainBadge;
List<TestUser> testUserList = [];

void main() async {
  //print('앱시작 : ${DateTime.now()}');
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과의 바인딩을 초기화합니다.

  await fetchSession();

  print('세션 로드 끝 : ${DateTime.now()}');
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
  //print('Provider create 끝 : ${DateTime.now()}');
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
        home: FutureProvider(
          create: (context) => QuestProvider().fetchQuest(),
          initialData: Center(
            child: CircularProgressIndicator(),
          ),
          child: QuestListPage(),
        ));
  }
}

class SplashScreen extends StatelessWidget {
  Future<void> _loadResources(BuildContext context) async {
    print('로드 시작 : ${DateTime.now()}');
    await Future.wait([
      loadFonts(),
    ]);

    print('로드 끝 : ${DateTime.now()}');
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}
