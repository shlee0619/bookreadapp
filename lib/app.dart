import 'package:flutter/material.dart';
import 'features/home/home_shell.dart';
import 'theme/app_theme.dart';

class BooklogApp extends StatelessWidget {
  const BooklogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booklog',
      debugShowCheckedModeBanner: false,
      theme: buildBooklogTheme(),
      home: const HomeShell(),
    );
  }
}
