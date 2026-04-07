import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'entrance_screen.dart';
import 'intro_screen.dart';
import 'notification_service.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'thema/app_color.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // 1. 반환값을 widgetsBinding 변수에 할당합니다. ✅
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. 초기화 작업 시작 전 런치스크린을 고정합니다. ✅
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. 비동기 초기화 작업들
  await Firebase.initializeApp();
  await NotificationService().init();

  // 4. (선택 사항) 로고를 더 보여주고 싶다면 딜레이 추가
  await Future.delayed(const Duration(seconds: 2));

  // 5. 모든 준비가 끝났으므로 런치스크린을 제거합니다. ✅
  FlutterNativeSplash.remove();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WooGo',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'KidariFont',
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                surface: AppColors.background, // 배경색으로 활용
                onSurface: AppColors.navy06,       // 배경 위 글자색
              ),
            ),
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            // ★ [핵심 수정] home 부분을 상태 감시자로 변경합니다.
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // 1. 연결 상태가 대기 중일 때 로딩 표시
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                // 2. 로그인된 유저 정보가 있다면 IntroScreen으로 진입
                // IntroScreen 내부에서 householdId 존재 여부를 한 번 더 체크하게 됩니다.
                if (snapshot.hasData) {
                  return IntroScreen();
                }

                // 3. 로그아웃 상태이거나 데이터가 없다면 EntranceScreen으로 이동
                return EntranceScreen();
              },
            ),
          );
        },
      ),
    );
  }
}