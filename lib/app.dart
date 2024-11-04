import 'package:flutter/material.dart';
import 'controllers/control_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Material App',
      theme: ThemeData(
        // nao funciona
        appBarTheme: const AppBarTheme(color: Colors.indigo),
        scaffoldBackgroundColor: const Color.fromARGB(255, 228, 228, 228),
        //primarySwatch: Colors.indigo, // nao funciona
      ), // nao funciona

      home: const ControlPage(),
    );
  }
}
