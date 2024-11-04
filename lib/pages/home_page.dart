import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () => {}, // Precisa Implementar
            icon: const Icon(
              Icons.swap_vert,
              size: 30,
            ),
          ),
        ],
        elevation: 2,
        backgroundColor: const Color(0xcaf4e733),
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
        title: Text('Quantidade: ${selecionadas.length}'),
        actions: [
          IconButton(
            onPressed: () => {}, // Precisa Implementar o sort
            icon: const Icon(
              Icons.swap_vert,
              size: 25,
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
      body: Column(
        children: [
          const Row(
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
          ),
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
                            child: Image.asset(
                              tarefa.icone,
                            ),
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
      ),
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
    );
  }
}
