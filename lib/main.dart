import 'package:flutter/material.dart';
import 'package:visitkorea/questListPage/questListPage.dart';
import 'model/quest.dart';
import 'jsonLoader.dart';
import 'package:provider/provider.dart';
import 'model/userInfo.dart';
import 'package:flutter/services.dart';
import 'dart:js' as js;

bool isEventAccept = false; // 이벤트 참여동의 여부
UserSession? userSession;
Badge_completed? mainBadge;

void main() async {
  // Provider 설정.
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
  //print('Provider create 끝 : ${DateTime.now()}');
}

// 폰트를 미리 불러오기
Future<void> loadFonts(BuildContext context) async {
  print('폰트 로드 시작');

  var fontLoader = FontLoader('NotoSansKR');

  // 모든 폰트 로딩
  fontLoader.addFont(fetchFont('assets/fonts/NotoSansKR-Regular.woff'));
  fontLoader.addFont(fetchFont('assets/fonts/NotoSansKR-Medium.woff'));
  fontLoader.addFont(fetchFont('assets/fonts/NotoSansKR-Bold.woff'));

  await fontLoader.load();
  print('폰트로드 완료');
  // await Future.wait([
  //   Provider.of<UserPrivacyInfoProvider>(context, listen: false)
  //       .fetchUserPrivacyInfo(),
  //   Provider.of<UserInfoProvider>(context, listen: false).fetchUserInfo()
  // ]);
}

Future<ByteData> fetchFont(String path) async {
  print(path);
  return await rootBundle.load(path);
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
      home: FutureBuilder(
        future: loadFonts(context),
        builder: (context, snapshot) {
          // FutureBuilder는 future가 완료되면 builder를 다시 호출합니다.
          if (snapshot.connectionState == ConnectionState.done) {
            // 지연 후 QuestListPage를 표시합니다.
            return Scaffold(body: QuestListPage());
          } else {
            // 지연이 진행되는 동안 로딩 인디케이터를 표시할 수 있습니다.
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
      navigatorObservers: [MyNavigatorObserver()],
    );
  }
}

// 페이지 이동시 같이 호출되는 ga태그 수신 클래스
class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendPageView(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _sendPageView(newRoute.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sendPageView(route.settings.name);
  }

  void _sendPageView(String? pageName) {
    print('sendPageView $pageName');
    if (pageName != null) {
      js.context.callMethod('gtag', [
        'config',
        'G-LYY1LJZCC4',
        js.JsObject.jsify({'page_path': pageName, 'page_title': pageName})
      ]);
    }
  }
}
