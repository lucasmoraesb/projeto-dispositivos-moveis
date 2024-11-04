import 'package:flutter/material.dart';
import 'controllers/paginas_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Material App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.indigo,
          elevation: 2,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 228, 228, 228),
      ),
      home: const PaginasController(),
    );
  }
}
