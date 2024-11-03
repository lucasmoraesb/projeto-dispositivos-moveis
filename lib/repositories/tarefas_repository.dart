import '../models/tarefa.dart';

class TarefasRepository {
  bool isSorted = false;
  static List<Tarefa> tabela = [
    Tarefa(
      nome: 'teste0[0]',
      data: DateTime.parse('2024-04-02'),
      descricao: 'não tenho nada para descrever',
    ),
    Tarefa(
      nome: 'teste2[1]',
      data: DateTime.parse('1999-07-03'),
      descricao: 'as vezes yes as vezes no',
    ),
    Tarefa(
      nome: 'teste1[2]',
      data: DateTime.parse('2025-10-03'),
      descricao: 'talvez eu tenha algo para descrever',
    ),
  ];

  sort() {}
}
