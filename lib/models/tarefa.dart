class Tarefa {
  String nome;
  DateTime data;
  String descricao;
  String responsavel;
  String? status = 'Não concluída';

  Tarefa({
    required this.nome,
    required this.data,
    required this.responsavel,
    required this.descricao,
    this.status,
  });
}
