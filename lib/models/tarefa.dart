class Tarefa {
  String nome;
  String icone;
  DateTime data; // formato esperado "ano-mês-dia" ""1984–04–02"
  String descricao;
  String status =
      'Não iniciado'; // !!!!!!!! ALTERAR DEPOIS (DEIXAR DINAMICO)!!!!!!!!!!!!!!!

  Tarefa({
    required this.nome,
    required this.icone,
    required this.data,
    required this.descricao,
  });
}
