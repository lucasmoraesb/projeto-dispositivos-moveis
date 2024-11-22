import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o novo arquivo de card
import '../repositories/tarefas_favoritas_repository.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import '../pages/nova_tarefa_page.dart';
import '../models/tarefa.dart';
import '../widgets/tarefa_card.dart';

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
                return TarefaCard(
                  tarefa: tarefa,
                  selecionadas: selecionadas,
                  onTap: (Tarefa tarefa) {
                    selecionadas.isEmpty
                        ? mostrarDetalhes(tarefa)
                        : setState(() {
                            (selecionadas.contains(tarefa))
                                ? selecionadas.remove(tarefa)
                                : selecionadas.add(tarefa);
                          });
                  },
                  onLongPress: (Tarefa tarefa) {
                    setState(() {
                      (selecionadas.contains(tarefa))
                          ? selecionadas.remove(tarefa)
                          : selecionadas.add(tarefa);
                    });
                  },
                  onDelete: (Tarefa tarefa) {
                    excluirTarefa(tarefa);
                    mostrarSnackBar(
                        'Tarefa "${tarefa.nome}" excluída com sucesso!');
                  },
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
