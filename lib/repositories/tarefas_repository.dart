import '../models/tarefa.dart';

class TarefasRepository {
  bool isSorted = false;
  static List<Tarefa> tabela = [
    Tarefa(
      nome: 'teste0[0]',
      icone: 'images/symbol_ok.png',
      data: '2024–04–02',
      descricao: 'não tenho nada para descrever',
    ),
    Tarefa(
      nome: 'teste2[1]',
      icone: 'images/symbol_ok.png',
      data: '1999-07-03',
      descricao: 'as vezes yes as vezes no',
    ),
    Tarefa(
      nome: 'teste1[2]',
      icone: 'images/symbol_ok.png',
      data: '2025-10-03',
      descricao: 'talvez eu tenha algo para descrever',
    ),
  ];

  sort() {}
}
