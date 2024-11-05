import 'package:flutter/material.dart';
import 'controllers/control_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Material App',
      theme: ThemeData(
        // nao funciona
        appBarTheme: const AppBarTheme(color: Color(0xFF3787eb)),
        scaffoldBackgroundColor: const Color.fromARGB(255, 247, 247, 247),
        //primarySwatch: Colors.indigo, // nao funciona
      ), // nao funciona

      home: const ControlPage(),
    );
  }
}
