import 'package:flutter/material.dart';

class Tarefa {
  String nome;
  DateTime data;
  String descricao;
  String status = 'Não iniciado';

  Tarefa({
    required this.nome,
    required this.data,
    required this.descricao,
  });
}
