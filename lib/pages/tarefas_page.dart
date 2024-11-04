import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import '../pages/NovaTarefaPage.dart';
import 'package:intl/intl.dart';

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
        ),
        elevation: 2,
        backgroundColor: Colors.blueGrey[50],
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
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
    
  sortData(tabela) {
    tabela.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);
    //favoritas = context.watch<TarefasFavoritasRepository>();
    List<Tarefa> tabela = TarefasRepository.tabela;
    sortData(tabela);

    /*  Teste de criação de nova tarefa na Tebela, pela própria "tarefas_page"
    Tarefa tarefinha = Tarefa(
      nome: 'teste9[3]',
      icone: 'images/symbol_ok.png',
      data: DateTime(2024, 11, 5),
      descricao: 'É isso Pessoal',
    );

    tabela.add(tarefinha);
    */
    //favoritas.sort();

    return Scaffold(
      appBar: appBarDinamica(),
      body: ListView.builder(
        itemCount: tabela.length,
        itemBuilder: (BuildContext context, int index) {
          final tarefa = tabela[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        Icon(Icons.star, color: Colors.amber, size: 25),
                    ],
                  ),
                  trailing: Text(
                    DateFormat('dd/MM/yyyy').format(tarefa.data),
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  if (favoritas.lista.contains(tabela[tarefa]))
                    const Icon(Icons.circle, color: Colors.amber, size: 8),
                ],
              ),
              trailing: Text(
                DateFormat('dd/MM/yyyy').format(tabela[tarefa].data),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),

              //tileColor: Color(0xefbebdbd),
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
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
