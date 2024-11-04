import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefasRepository extends ChangeNotifier {
  late bool isSorted = false;
  static List<Tarefa> tabela = [
    Tarefa(
      nome: 'teste0[0]',
      icone: 'images/symbol_ok.png',
      data: DateTime(2017, 1, 2),
      descricao: 'não tenho nada para descrever',
    ),
    Tarefa(
      nome: 'teste2[1]',
      icone: 'images/symbol_ok.png',
      data: DateTime(1999, 07, 03),
      descricao: 'as vezes yes as vezes no',
    ),
    Tarefa(
      nome: 'teste1[2]',
      icone: 'images/symbol_ok.png',
      data: DateTime(2025, 10, 3),
      descricao: 'talvez eu tenha algo para descrever',
    ),
    Tarefa(
      nome: 'Teste Home',
      icone: 'images/symbol_ok.png',
      data: DateTime(2025, 10, 03),
      descricao: 'talvez eu tenha algo para descrever',
    ),
  ];
  /*
  adicionarTarefa(){

  }*/
/*
  List<Tarefa> pegarDados() => tabela;

  sortData() {
    if (isSorted) {
      return tabela;
    } else {
      isSorted = false;
      return tabela.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
    }
    //tabela.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
  }*/
}
