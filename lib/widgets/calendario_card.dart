import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../repositories/casas_repository.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import '../widgets/tarefa_card.dart';

class CalendarioCard extends StatefulWidget {
  final DateTime selectedDate;

  const CalendarioCard({super.key, required this.selectedDate});

  @override
  State<CalendarioCard> createState() => _CalendarioCardState();
}

class _CalendarioCardState extends State<CalendarioCard> {
  List<Tarefa> selecionadas = [];
  String? _filtroUsername; // Filtro por username

  void mostrarDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarefasDescricaoPage(tarefa: tarefa),
      ),
    );
  }

  void showAlertDialog(BuildContext context, Function onConfirm) {
    Widget cancelaButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continuaButton = TextButton(
      child: const Text("Continuar"),
      onPressed: () {
        onConfirm();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Confirmação"),
      content: const Text("Deseja realmente excluir as tarefas selecionadas?"),
      actions: [
        cancelaButton,
        continuaButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final casasRepo = Provider.of<CasasRepository>(context);
    final tarefasRepo = Provider.of<TarefasRepository>(context);
    final senhaCasa = casasRepo.senhaCasaAtual;
    final formattedDate =
        DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR').format(widget.selectedDate);

    // Lista de membros da casa para o filtro
    final membros = casasRepo.obterMembrosDaCasa();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(formattedDate),
      ),
      body: Column(
        children: [
          // Dropdown para o filtro por responsável
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _filtroUsername,
              decoration:
                  const InputDecoration(labelText: 'Filtrar por responsável'),
              items: membros.map((membro) {
                return DropdownMenuItem<String>(
                  value: membro,
                  child: Text(membro),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _filtroUsername = valor;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              future: tarefasRepo.getTarefasPorSenhaCasa(senhaCasa).first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma tarefa para esta data'));
                }

                // Filtrar tarefas pela data selecionada e pelo responsável
                final tarefasFiltradas = snapshot.data!.where((tarefa) {
                  final isSameDate =
                      tarefa.data.year == widget.selectedDate.year &&
                          tarefa.data.month == widget.selectedDate.month &&
                          tarefa.data.day == widget.selectedDate.day;
                  final matchesFilter = _filtroUsername == null ||
                      tarefa.responsavel == _filtroUsername;

                  return isSameDate && matchesFilter;
                }).toList();

                if (tarefasFiltradas.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma tarefa para esta data'));
                }

                return ListView.builder(
                  itemCount: tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefasFiltradas[index];
                    return TarefaCard(
                      tarefa: tarefa,
                      selecionadas: selecionadas,
                      onTap: (tarefa) {
                        if (selecionadas.isEmpty) {
                          mostrarDetalhes(tarefa);
                        } else {
                          setState(() {
                            if (selecionadas.contains(tarefa)) {
                              selecionadas.remove(tarefa);
                            } else {
                              selecionadas.add(tarefa);
                            }
                          });
                        }
                      },
                      onLongPress: (tarefa) {
                        setState(() {
                          if (selecionadas.contains(tarefa)) {
                            selecionadas.remove(tarefa);
                          } else {
                            selecionadas.add(tarefa);
                          }
                        });
                      },
                      onDelete: (tarefa) {
                        showAlertDialog(context, () async {
                          await tarefasRepo.removerTarefa(senhaCasa, tarefa);
                          setState(() {});
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.delete),
              label: const Text('Remover'),
              onPressed: () {
                showAlertDialog(context, () async {
                  final tarefasRepo =
                      Provider.of<TarefasRepository>(context, listen: false);
                  for (var tarefa in selecionadas) {
                    await tarefasRepo.removerTarefa(senhaCasa, tarefa);
                  }
                  setState(() {
                    selecionadas.clear();
                  });
                });
              },
            )
          : null,
    );
  }
}
