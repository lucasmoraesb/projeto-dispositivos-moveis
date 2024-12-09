import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../widgets/tarefa_card.dart';
import '../pages/tarefas_descricao_page.dart';

class CalendarioCard extends StatefulWidget {
  final DateTime selectedDate;

  const CalendarioCard({super.key, required this.selectedDate});

  @override
  State<CalendarioCard> createState() => _CalendarioCardState();
}

class _CalendarioCardState extends State<CalendarioCard> {
  List<Tarefa> selecionadas =
      []; // Lista para armazenar as tarefas selecionadas

  List<Tarefa> _getTarefasForSelectedDate() {
    // Filtra as tarefas pela data selecionada
    return TarefasRepository.tabela.where((tarefa) {
      return tarefa.data.year == widget.selectedDate.year &&
          tarefa.data.month == widget.selectedDate.month &&
          tarefa.data.day == widget.selectedDate.day;
    }).toList();
  }

  // Função para mostrar os detalhes da tarefa
  mostrarDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarefasDescricaoPage(tarefa: tarefa),
      ),
    );
  }

  // Função para excluir tarefas selecionadas
  excluirTarefas() {
    setState(() {
      for (var tarefa in List.from(selecionadas)) {
        if (TarefasRepository.tabela.contains(tarefa)) {
          TarefasRepository.tabela.remove(tarefa);
        }
      }
      selecionadas.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefas excluídas com sucesso!')),
    );
  }

  // Função para exibir o diálogo de confirmação
  showAlertDialog(BuildContext context, Function onConfirm) {
    Widget cancelaButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop(); // Fecha o diálogo
      },
    );

    Widget continuaButton = TextButton(
      child: const Text("Continuar"),
      onPressed: () {
        onConfirm(); // Chama a função de confirmação
        Navigator.of(context).pop(); // Fecha o diálogo
      },
    );

    // Configura o AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmação"),
      content: const Text("Deseja realmente excluir as tarefas selecionadas?"),
      actions: [
        cancelaButton,
        continuaButton,
      ],
    );

    // Exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as tarefas para a data selecionada
    final tarefas = _getTarefasForSelectedDate();
    final formattedDate =
        DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR').format(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(formattedDate),
      ),
      body: tarefas.isEmpty
          ? const Center(child: Text('Nenhuma tarefa para esta data'))
          : ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                return TarefaCard(
                  tarefa: tarefa,
                  selecionadas: selecionadas,
                  onTap: (Tarefa tarefa) {
                    if (selecionadas.isEmpty) {
                      mostrarDetalhes(
                          tarefa); // Vai para a tela de detalhes se não houver seleção
                    } else {
                      setState(() {
                        if (selecionadas.contains(tarefa)) {
                          selecionadas
                              .remove(tarefa); // Remove a tarefa da seleção
                        } else {
                          selecionadas
                              .add(tarefa); // Adiciona a tarefa à seleção
                        }
                      });
                    }
                  },
                  onLongPress: (Tarefa tarefa) {
                    setState(() {
                      if (selecionadas.contains(tarefa)) {
                        selecionadas
                            .remove(tarefa); // Remove a tarefa da seleção
                      } else {
                        selecionadas.add(tarefa); // Adiciona a tarefa à seleção
                      }
                    });
                  },
                  onDelete: (Tarefa tarefa) {
                    excluirTarefas(); // Passa a função para excluir a tarefa
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Tarefa "${tarefa.nome}" excluída com sucesso!'),
                    ));
                  },
                );
              },
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mostrar o botão de remover se houver tarefas selecionadas
            selecionadas.isNotEmpty
                ? FloatingActionButton.extended(
                    icon: const Icon(Icons.delete),
                    label: const Text(
                      'Remover',
                      style: TextStyle(letterSpacing: 0),
                    ),
                    onPressed: () {
                      showAlertDialog(context,
                          excluirTarefas); // Exibe o diálogo de confirmação
                    },
                  )
                : const SizedBox(width: 0),
          ],
        ),
      ),
    );
  }
}
