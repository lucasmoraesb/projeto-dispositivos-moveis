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
        /*
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0), // Adiciona padding-top
          
          child: Text(
            'Minhas Tarefas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
        ),*/
        centerTitle: true,
        title: const Text('Minhas Tarefas'),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 25,
        ),
        elevation: 2,
        //backgroundColor: Colors.blueGrey[50],
        titleSpacing: 46, // Alinha o título à esquerda
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

  sortData(tabela) {
    tabela.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);
    //tarefasRepo = Provider.of<TarefasRepository>(context);
    //List<Tarefa> tabela = tarefas.getAll();
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
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //floatingBarDinamica();
      floatingActionButton: /* selecionadas.isNotEmpty
          ?  */
          Align(
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
                      for (var tarefa in selecionadas) {
                        if (selecionadas.contains(tarefa)) {
                          try {
                            tabela.remove(tarefa);
                          } catch (e) {
                            throw 'Erro ao remover tarefa';
                          }
                        }
                      }
                      limparSelecionadas();
                    },
                  ) /* , */
                : const SizedBox(width: 0),
            //foregroundColor: const Color.fromARGB(255, 248, 8, 8),
            const SizedBox(width: 120),
            FloatingActionButton.extended(
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
          ],
        ),
      ),
    );
  }
}
