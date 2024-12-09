import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';

import 'nova_tarefa_page.dart';
import '../widgets/tarefa_card.dart';
import '../pages/configuracoes_page.dart'; // Importe o TarefaCard

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarefa> selecionadas = [];
  late TarefasFavoritasRepository favoritas;

  appBarDinamica() {
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

  mostrarConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfiguracoesPage(),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  excluirTarefasSelecionadas() {
    setState(() {
      for (var tarefa in selecionadas) {
        TarefasRepository.tabela.remove(tarefa);
      }
      selecionadas.clear(); // Limpa a lista de selecionadas
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

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);

    // Filtra as tarefas para mostrar apenas as do dia atual
    final hoje = DateTime.now();
    final tarefasDoDia = TarefasRepository.tabela.where((tarefa) {
      return tarefa.data.year == hoje.year &&
          tarefa.data.month == hoje.month &&
          tarefa.data.day == hoje.day;
    }).toList();

    return Scaffold(
      appBar: appBarDinamica(),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFFFFF),
        child: ListView(
          children: [
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(
                    right: 8.0), // Adiciona um padding à direita do ícone
                child: Icon(Icons.settings), // Ícone de engrenagem
              ),
              title: const Text('Configurações'),
              onTap: () {
                mostrarConfiguracoes();
              },
            ),
          ],
        ),
      ),
      body: tarefasDoDia.isEmpty
          ? const Center(
              child: Text(
                'Sem tarefas hoje',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: tarefasDoDia.length,
              itemBuilder: (BuildContext context, int index) {
                final tarefa = tarefasDoDia[index];
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
                    excluirTarefasSelecionadas();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Tarefa "${tarefa.nome}" excluída com sucesso!')));
                  },
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                          excluirTarefasSelecionadas();

                          // Exibir mensagem com o número de tarefas removidas
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tarefa(s) removida(s) com sucesso!',
                              ),
                            ),
                          );
                        });
                      }
                    },
                  )
                : const SizedBox(width: 0),
            const SizedBox(width: 120),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FloatingActionButton.extended(
                backgroundColor: const Color.fromARGB(255, 96, 126, 201),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NovaTarefaPage()),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFFFFFFFF),
                ),
                label: const Text(
                  'Criar Tarefa',
                  style: TextStyle(letterSpacing: 0, color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


               

/*     return Scaffold(
      appBar: appBarDinamica(),
      body: Column(
        children: [
          /* const Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 20, 0, 10), // Caso deseje um espaçamento específico
                child: Text(
                  'Tarefas do dia',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ), */
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final tarefa = tarefasDoDia[index];
                  return ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    leading: (selecionadas.contains(tarefa))
                        ? const CircleAvatar(
                            child: Icon(Icons.check),
                          )
                        : SizedBox(
                            width: 25,
                            height: 25,
                            /*child: Image.asset( // @@@@ Arrumar Depois @@@@
                              tarefa.icone,
                            ),*/
                          ),
                    title: Row(
                      children: [
                        Text(
                          tarefa.nome,
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        if (favoritas.lista.contains(tarefa))
                          const Icon(Icons.circle,
                              color: Colors.amber, size: 8),
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
                  );
                },
                padding: const EdgeInsets.all(20),
                separatorBuilder: (_, ___) => const Divider(),
                itemCount: tarefasDoDia.length),
          ),
        ],
      ), //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritas.saveAll(selecionadas);
                limparSelecionadas();
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'FAVORITAR',
                style: TextStyle(
                  letterSpacing: 0,
                ),
              ),
            )
          : null,
    ); */