import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tedxlearn/pages/login.dart';
import 'package:tedxlearn/styles/stile.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TEDxLearn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.backgroundColor,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.backgroundColor,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: const Login(),
    );
  }
}
