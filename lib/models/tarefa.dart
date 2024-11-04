class Tarefa {
  String nome;
  DateTime data;
  String descricao;
  String status = 'Não concluída';

  Tarefa({
    required this.nome,
    required this.data,
    required this.descricao,
  });
}
