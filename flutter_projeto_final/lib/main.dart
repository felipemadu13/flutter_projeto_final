import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/ui/page/login_screen.dart';
import 'package:flutter_projeto_final/ui/page/schedule_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/schedule': (context) => const ScheduleScreen(), // Adicionamos esta rota
      },
    );
  }
}
