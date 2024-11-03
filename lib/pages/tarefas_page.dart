import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import 'NovaTarefaPage.dart';

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
        title: const Text('AppBar_0'),
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
              color: Colors.yellow,
              size: 25,
            ),
          ),
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
    final tabela = TarefasRepository.tabela;

    return Scaffold(
      appBar: appBarDinamica(),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int tarefa) {
          return ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            leading: (selecionadas.contains(tabela[tarefa]))
                ? const CircleAvatar(
                    child: Icon(Icons.check),
                  )
                : SizedBox(
                    width: 25,
                    height: 25,
                    child: Image.asset(
                      tabela[tarefa].icone,
                    ),
                  ),
            title: Row(
              children: [
                Text(
                  tabela[tarefa].nome,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                ),
                if (favoritas.lista.contains(tabela[tarefa]))
                  Icon(Icons.circle, color: Colors.amber, size: 8),
              ],
            ),
            trailing: Text(
              tabela[tarefa].data,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            selected: selecionadas.contains(tabela[tarefa]),
            selectedTileColor: const Color(0xff4a61e7),
            onLongPress: () {
              setState(() {
                (selecionadas.contains(tabela[tarefa]))
                    ? selecionadas.remove(tabela[tarefa])
                    : selecionadas.add(tabela[tarefa]);
              });
            },
            onTap: () {
              selecionadas.isEmpty
                  ? mostrarDetalhes(tabela[tarefa])
                  : setState(() {
                      (selecionadas.contains(tabela[tarefa]))
                          ? selecionadas.remove(tabela[tarefa])
                          : selecionadas.add(tabela[tarefa]);
                    });
            },
          );
        },
        padding: const EdgeInsets.all(20),
        separatorBuilder: (_, ___) => const Divider(),
        itemCount: tabela.length,
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NovaTarefaPage()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
