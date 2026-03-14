import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home_screen.dart';
import 'entrance_screen.dart';
import 'intro_screen.dart';
import 'notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(), // 이전에 만든 LocaleProvider 클래스
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'WooGo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'KidariFont',
            ),
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: IntroScreen(),
          );
        },
      ),
    );
  }
}