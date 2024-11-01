import 'dart:collection';

import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefasFavoritasRepository extends ChangeNotifier {
  List<Tarefa> _lista = [];

  UnmodifiableListView<Tarefa> get lista => UnmodifiableListView(_lista);

  saveAll(List<Tarefa> tarefas) {
    for (var tarefa in tarefas) {
      if (!_lista.contains(tarefa)) _lista.add(tarefa);
    }
    notifyListeners();
  }

  remove(Tarefa tarefa) {
    _lista.remove(tarefa);
    notifyListeners();
  }
}
