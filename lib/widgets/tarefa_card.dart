import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../repositories/tarefas_repository.dart';

class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final List<Tarefa> selecionadas;
  final ValueChanged<Tarefa> onTap;
  final ValueChanged<Tarefa> onLongPress;
  final Function onDelete;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.selecionadas,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            leading: (selecionadas.contains(tarefa))
                ? const CircleAvatar(
                    child: Icon(Icons.check),
                  )
                : CircleAvatar(
                    child: Icon(
                      tarefa.status == 'Concluído'
                          ? Icons.check_circle
                          : Icons.circle,
                    ),
                  ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    tarefa.nome,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                if (TarefasFavoritasRepository().lista.contains(tarefa))
                  const Icon(Icons.star, color: Colors.amber, size: 25),
              ],
            ),
            trailing: Text(
              DateFormat('dd/MM/yyyy').format(tarefa.data),
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            selected: selecionadas.contains(tarefa),
            selectedTileColor: const Color(0xff4a61e7),
            onLongPress: () => onLongPress(tarefa),
            onTap: () => onTap(tarefa),
          ),
          if (tarefa.status == 'Concluído')
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tarefa.descricao,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(tarefa),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
