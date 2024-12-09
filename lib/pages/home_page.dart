import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../pages/tarefas_descricao_page.dart';
import 'nova_tarefa_page.dart';
import '../widgets/tarefa_card.dart';
import '../pages/configuracoes_page.dart';
import '../repositories/casas_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarefa> selecionadas = [];
  late TarefasFavoritasRepository favoritas;
  String? _filtroUsername; // Username selecionado para filtro

  AppBar appBarDinamica() {
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

  excluirTarefasSelecionadas() async {
    final casasRepo = Provider.of<CasasRepository>(context, listen: false);
    final senhaCasa = casasRepo.senhaCasaAtual;

    for (var tarefa in selecionadas) {
      final tarefasRepo =
          Provider.of<TarefasRepository>(context, listen: false);
      await tarefasRepo.removerTarefa(senhaCasa, tarefa);
    }

    setState(() {
      selecionadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);
    final casasRepo = Provider.of<CasasRepository>(context);
    final senhaCasa = casasRepo.senhaCasaAtual;

    // Obter lista de membros da casa
    final membros = casasRepo.obterMembrosDaCasa();
    print(membros);

    return Scaffold(
      appBar: appBarDinamica(),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFFFFF),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                mostrarConfiguracoes();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Dropdown para filtro por username
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _filtroUsername,
              decoration:
                  const InputDecoration(labelText: 'Filtrar por responsável'),
              items: membros.map((membro) {
                return DropdownMenuItem<String>(
                  value: membro,
                  child: Text(membro),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _filtroUsername = valor; // Atualiza o filtro
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              future: Provider.of<TarefasRepository>(context)
                  .getTarefasDoDia(senhaCasa),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Sem tarefas hoje',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                // Filtrar tarefas com base no username selecionado
                final tarefasFiltradas = snapshot.data!
                    .where((tarefa) =>
                        _filtroUsername == null ||
                        tarefa.responsavel == _filtroUsername)
                    .toList();

                return tarefasFiltradas.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem tarefas hoje',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tarefasFiltradas.length,
                        itemBuilder: (context, index) {
                          final tarefa = tarefasFiltradas[index];
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
                            onDelete: (Tarefa tarefa) async {
                              await excluirTarefasSelecionadas();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Tarefa "${tarefa.nome}" excluída com sucesso!')));
                            },
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 96, 126, 201),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovaTarefaPage(),
            ),
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
    );
  }
}
