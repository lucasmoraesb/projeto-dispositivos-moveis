import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import '../pages/NovaTarefaPage.dart';

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> selecionadas = [];
  late TarefasFavoritasRepository favoritas;

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        centerTitle: true,
        title: const Text('Minhas Tarefas',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
        title: Text('Tarefas: ${selecionadas.length}'),
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
        backgroundColor: Colors.blueGrey[50],
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
    });
  }

  editarTarefa(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovaTarefaPage(tarefa: tarefa),
      ),
    ).then((_) {
      // Limpa a seleção ao voltar
      setState(() {
        selecionadas.clear();
      });
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
      body: ListView.builder(
        itemCount: tabela.length,
        itemBuilder: (BuildContext context, int index) {
          final tarefa = tabela[index];
          return Card(
            color: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: (selecionadas.contains(tarefa))
                      ? const CircleAvatar(
                          child: Icon(Icons.check),
                        )
                      : CircleAvatar(
                          child: Icon(
                            tarefa.status == 'Concluído'
                                ? Icons.check_circle
                                : Icons.circle,
                            color: Colors.white,
                          ),
                        ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tarefa.nome,
                          style: TextStyle(
                            fontSize: 25,
                            color: selecionadas.contains(tarefa)
                                ? Colors.white // Texto branco se selecionado
                                : Colors
                                    .black, // Cor original se não selecionado
                          ),
                        ),
                      ),
                      if (favoritas.lista.contains(tarefa))
                        const Icon(Icons.star, color: Colors.amber, size: 25),
                    ],
                  ),
                  trailing: Text(
                    DateFormat('dd/MM/yyyy').format(tarefa.data),
                    style: TextStyle(
                      fontSize: 15,
                      color: selecionadas.contains(tarefa)
                          ? Colors.white // Data branca se selecionada
                          : Colors.black, // Cor original se não selecionada
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
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
                // Adicionando um botão de editar
                if (selecionadas.contains(tarefa))
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editarTarefa(tarefa),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF3787eb),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NovaTarefaPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
