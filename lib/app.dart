import 'package:flutter/material.dart';
import 'features/home/home_shell.dart';
import 'theme/app_theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

class BooklogApp extends StatelessWidget {
  const BooklogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booklog',
      debugShowCheckedModeBanner: false,
      theme: buildBooklogTheme(Brightness.light),
      darkTheme: buildBooklogTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ko')],
      home: const HomeShell(),
    );
  }
}
