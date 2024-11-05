import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import '../pages/nova_tarefa_page.dart';

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> selecionadas = [];
  late TarefasFavoritasRepository favoritas;
  late TarefasRepository tarefasRepo;

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        centerTitle: true,
        title: const Text('Minhas Tarefas'),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
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
        title: const Text('Tarefas selecionadas'),
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
              size: 25,
              color: Colors.amber,
            ),
          ),
        ],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 25,
        ),
      );
    }
  }

  mostrarDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarefasDescricaoPage(tarefa: tarefa),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  void mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
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
    setState(() {
      TarefasRepository.tabela.remove(tarefa);
      mostrarSnackBar('Tarefa excluída com sucesso!'); // Exibe o SnackBar aqui
    });
  }

  sortData(tabela) {
    tabela.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);
    List<Tarefa> tabela = TarefasRepository.tabela;
    sortData(tabela);

    return Scaffold(
      appBar: appBarDinamica(),
      body: tabela.isEmpty
          ? const Center(
              child: Text(
                'Não existem tarefas',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: tabela.length,
              itemBuilder: (BuildContext context, int index) {
                final tarefa = tabela[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            if (favoritas.lista.contains(tarefa))
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 25),
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
                        onLongPress: () {
                          setState(() {
                            (selecionadas.contains(tarefa))
                                ? selecionadas.remove(tarefa)
                                : selecionadas.add(tarefa);
                          });
                        },
                        onTap: () {
                          selecionadas.isEmpty
                              ? mostrarDetalhes(tarefa)
                              : setState(() {
                                  (selecionadas.contains(tarefa))
                                      ? selecionadas.remove(tarefa)
                                      : selecionadas.add(tarefa);
                                });
                        },
                      ),
                      if (tarefa.status == 'Concluído')
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 8.0),
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  excluirTarefa(tarefa);
                                  mostrarSnackBar(
                                      'Tarefa "${tarefa.nome}" excluída com sucesso!'); // Mensagem específica para a tarefa
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            selecionadas.isNotEmpty
                ? FloatingActionButton.extended(
                    icon: const Icon(Icons.delete),
                    label: const Text(
                      'Remover',
                      style: TextStyle(
                        letterSpacing: 0,
                      ),
                    ),
                    onPressed: () {
                      if (selecionadas.isNotEmpty) {
                        // Chama o diálogo de confirmação
                        showAlertDialog2(context, selecionadas, () {
                          int tarefasRemovidas =
                              0; // Contador para tarefas removidas
                          for (var tarefa in List.from(selecionadas)) {
                            // Usar List.from para evitar modificar a lista durante a iteração
                            if (tabela.contains(tarefa)) {
                              tabela.remove(tarefa);
                              tarefasRemovidas++;
                            }
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
                : const SizedBox(width: 0),
            const SizedBox(width: 120),
            FloatingActionButton.extended(
              onPressed: () async {
                // Navegar para NovaTarefaPage e aguardar o resultado
                final novaTarefa = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NovaTarefaPage()),
                );

                // Se uma nova tarefa foi criada, atualize a tela
                if (novaTarefa != null) {
                  setState(() {
                    // Adicione a nova tarefa à lista
                    TarefasRepository.tabela.add(novaTarefa);
                  });

                  // Mostrar SnackBar informando que a tarefa foi criada
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Tarefa "${novaTarefa.nome}" criada com sucesso!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Criar Tarefa',
                style: TextStyle(
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
