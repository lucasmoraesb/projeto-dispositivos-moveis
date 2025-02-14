import 'tarefa.dart';

class Usuario {
  String id;
  String nome;
  String email;
  String? casaAtual;
  List<Tarefa> tarefas;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.casaAtual,
    required this.tarefas,
  });
}
