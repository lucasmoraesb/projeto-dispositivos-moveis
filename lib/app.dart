import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/widgets/auth_check.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Material App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.indigo,
          elevation: 2,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: const AuthCheck(),
    );
  }
}
