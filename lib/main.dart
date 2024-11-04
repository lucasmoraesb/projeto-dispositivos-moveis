import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/tarefas_favoritas_repository.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Inicializa a formatação da localidade para pt_BR
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => TarefasFavoritasRepository(),
        child: const App(),
      ),
    );
  });
}
