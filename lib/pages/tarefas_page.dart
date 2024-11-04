import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
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

  sortData(tabela) {
    tabela.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
  }

  formatarData(data) {
    var formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(data);
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
      body: ListView.separated(
          itemBuilder: (BuildContext context, int tarefa) {
            return ListTile(
              /*leading: Image.asset(tabela[tarefa].icone,width: 25, height: 25,),*/
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
                formatarData(tabela[tarefa].data),
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
          padding: const EdgeInsets.all(20),
          separatorBuilder: (_, ___) => const Divider(),
          itemCount: tabela.length),
      //backgroundColor: Color(0xd6166fa4),
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
