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
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
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

  void mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  excluirTarefa(Tarefa tarefa) {
    final tarefasRepo = Provider.of<TarefasRepository>(context, listen: false);
    tarefasRepo.removerTarefa(tarefa.responsavel, tarefa);
    mostrarSnackBar('Tarefa excluída com sucesso!'); // Exibe o SnackBar aqui
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);
    final tarefasRepo = Provider.of<TarefasRepository>(context);
    final casasRepo = Provider.of<CasasRepository>(context);
    final senhaCasa = casasRepo.senhaCasaAtual;

    // Obter lista de membros da casa
    final membros = casasRepo.obterMembrosDaCasa();

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
                            onDelete: (Tarefa tarefa) {
                              excluirTarefa(tarefa);
                              mostrarSnackBar(
                                  'Tarefa "${tarefa.nome}" excluída com sucesso!');
                            },
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            selecionadas.isNotEmpty
                ? FloatingActionButton.extended(
                    backgroundColor: const Color.fromARGB(255, 96, 126, 201),
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFFFFFFFF),
                    ),
                    label: const Text(
                      'Remover',
                      style:
                          TextStyle(letterSpacing: 0, color: Color(0xFFFFFFFF)),
                    ),
                    onPressed: () {
                      if (selecionadas.isNotEmpty) {
                        // Chama o diálogo de confirmação
                        showAlertDialog2(context, selecionadas, () {
                          int tarefasRemovidas =
                              0; // Contador para tarefas removidas
                          for (var tarefa in List.from(selecionadas)) {
                            tarefasRepo.removerTarefa(senhaCasa, tarefa);
                            tarefasRemovidas++;
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
          ],
        ),
      ),
    );
  }
}
