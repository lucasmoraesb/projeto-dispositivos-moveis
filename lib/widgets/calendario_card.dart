import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../repositories/casas_repository.dart';
import '../repositories/tarefas_favoritas_repository.dart';
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
  late TarefasFavoritasRepository favoritas;
  String? _filtroUsername;

  AppBar appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        centerTitle: true,
        title: const Text('Tarefas do Dia'),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 25,
        ),
        elevation: 2,
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          },
        ),
        centerTitle: true,
        title: const Text('Tarefas Selecionadas'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                for (var tarefa in selecionadas) {
                  if (!favoritas.lista.contains(tarefa)) {
                    favoritas.saveAll([tarefa]);
                  }
                }
                selecionadas = [];
              });
            },
            icon: const Icon(
              Icons.star,
              size: 30,
              color: Colors.amber,
            ),
          )
        ],
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 25,
        ),
      );
    }
  } // Filtro por username

  void mostrarDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarefasDescricaoPage(tarefa: tarefa),
      ),
    );
  }

  void mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  void showAlertDialog2(
      BuildContext context, List<Tarefa> selecionadas, Function onConfirm) {
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

  excluirTarefa(Tarefa tarefa) {
    final tarefasRepo = Provider.of<TarefasRepository>(context, listen: false);
    tarefasRepo.removerTarefa(tarefa.responsavel, tarefa);
    mostrarSnackBar('Tarefa excluída com sucesso!'); // Exibe o SnackBar aqui
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
      appBar: appBarDinamica(),
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
                      onDelete: (Tarefa tarefa) {
                        excluirTarefa(tarefa);
                        mostrarSnackBar(
                            'Tarefa "${tarefa.nome}" excluída com sucesso!');
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
              backgroundColor: const Color.fromARGB(255, 96, 126, 201),
              icon: const Icon(
                Icons.delete,
                color: Color(0xFFFFFFFF),
              ),
              label: const Text(
                'Remover',
                style: TextStyle(letterSpacing: 0, color: Color(0xFFFFFFFF)),
              ),
              onPressed: () {
                if (selecionadas.isNotEmpty) {
                  // Chama o diálogo de confirmação
                  showAlertDialog2(context, selecionadas, () {
                    int tarefasRemovidas = 0; // Contador para tarefas removidas
                    for (var tarefa in List.from(selecionadas)) {
                      tarefasRepo.removerTarefa(senhaCasa, tarefa);
                      tarefasRemovidas++;
                    }
                    limparSelecionadas();

                    // Exibir mensagem com o número de tarefas removidas
                    mostrarSnackBar(
                      '$tarefasRemovidas tarefa(s) removida(s) com sucesso!',
                    );
                  });
                }
              },
            )
          : null,
    );
  }
}
