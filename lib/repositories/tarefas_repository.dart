import '../models/tarefa.dart';

class TarefasRepository {
  bool isSorted = false;
  static List<Tarefa> tabela = [
    Tarefa(
      nome: 'teste0[0]',
      icone: 'images/symbol_ok.png',
      data: DateTime(2024, 4, 2),
      descricao: 'não tenho nada para descrever',
    ),
    Tarefa(
      nome: 'teste2[1]',
      icone: 'images/symbol_ok.png',
      data: DateTime(1999, 7, 3),
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
      data: DateTime(2024, 11, 4),
      descricao: 'talvez eu tenha algo para descrever',
    ),
  ];

  sort() {}
}
