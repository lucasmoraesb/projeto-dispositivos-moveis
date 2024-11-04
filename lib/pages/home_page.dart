import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import 'package:intl/intl.dart';

import 'nova_tarefa_page.dart';

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
        //backgroundColor: Colors.blueGrey[50],
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

  excluirTarefa(Tarefa tarefa) {
    setState(() {
      TarefasRepository.tabela.remove(tarefa);
      //tarefas.remove(tarefa);
    });
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
      body: ListView.builder(
        itemCount: tarefasDoDia.length,
        itemBuilder: (BuildContext context, int index) {
          final tarefa = tarefasDoDia[index];
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
                      if (favoritas.lista.contains(tarefa))
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
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => excluirTarefa(tarefa),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NovaTarefaPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Criar Tarefa',
          style: TextStyle(
            letterSpacing: 0,
          ),
        ),
      ),
    );
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
  }
}
