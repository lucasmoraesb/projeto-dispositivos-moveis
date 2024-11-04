import 'package:flutter/material.dart';

class ConcluidasPage extends StatefulWidget {
  const ConcluidasPage({super.key});

  @override
  State<ConcluidasPage> createState() => _ConcluidasPageState();
}

class _ConcluidasPageState extends State<ConcluidasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas concluídas'),
      ),
    );
  }
}
