import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/tarefas_favoritas_repository.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TarefasFavoritasRepository(),
      child: const App(),
    ),
  );
}
