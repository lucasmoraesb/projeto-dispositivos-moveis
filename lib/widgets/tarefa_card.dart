import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../pages/tarefas_descricao_page.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import 'package:intl/intl.dart';

class TarefaCard extends StatefulWidget {
  Tarefa tarefa;

  TarefaCard({super.key, required this.tarefa});

  @override
  State<TarefaCard> createState() => _TarefaCardState();
}

class _TarefaCardState extends State<TarefaCard> {
  static Map<String, Color> precoColor = <String, Color>{
    'up': Colors.teal,
    'down': Colors.indigo,
  };

  abrirDetalhes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarefasDescricaoPage(tarefa: widget.tarefa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => abrirDetalhes(),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
          child: Row(
            children: [
              Image.asset(
                widget.tarefa.icone,
                height: 40,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tarefa.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(widget.tarefa.data),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: precoColor['down']!.withOpacity(0.05),
                  border: Border.all(
                    color: precoColor['down']!.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  widget.tarefa.status,
                  style: const TextStyle(
                    fontSize: 14,
                    //color: preColor['down'],
                    letterSpacing: -1,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      child: ListTile(
                    title: const Text('Desfavoritar'),
                    onTap: () {
                      Navigator.pop(context);
                      Provider.of<TarefasFavoritasRepository>(context,
                              listen: false)
                          .remove(widget.tarefa);
                    },
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
