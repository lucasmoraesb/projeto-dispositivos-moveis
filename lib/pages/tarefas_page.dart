import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../repositories/tarefas_repository.dart';
import '../repositories/casas_repository.dart'; // Importando o casas_repository
import '../pages/tarefas_descricao_page.dart';
import '../pages/nova_tarefa_page.dart';
import '../models/tarefa.dart';
import '../widgets/tarefa_card.dart';
import 'configuracoes_page.dart';

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> selecionadas = [];
  String? filtroResponsavel; // Adicionado para o filtro
  late TarefasFavoritasRepository favoritas;

  mostrarConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfiguracoesPage(),
      ),
    );
  }

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        centerTitle: true,
        title: const Text('Tarefas'),
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

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  void mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
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

  excluirTarefa(Tarefa tarefa) {
    final tarefasRepo = Provider.of<TarefasRepository>(context, listen: false);
    tarefasRepo.removerTarefa(tarefa.responsavel, tarefa);
    mostrarSnackBar('Tarefa excluída com sucesso!'); // Exibe o SnackBar aqui
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<TarefasFavoritasRepository>(context);
    final tarefasRepo = Provider.of<TarefasRepository>(context);
    final casasRepo =
        Provider.of<CasasRepository>(context); // Obtendo o casasRepository

    // Verificando se senhaCasaAtual é nula antes de usá-la
    final senhaCasa = casasRepo.senhaCasaAtual;

    final membros =
        casasRepo.obterMembrosDaCasa(); // Obtém os membros para o filtro

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: filtroResponsavel,
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
                  filtroResponsavel = valor;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Tarefa>>(
              stream: tarefasRepo.getTarefasPorSenhaCasa(senhaCasa),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final tarefas = snapshot.data ?? [];
                final tarefasFiltradas = tarefas.where((tarefa) {
                  return filtroResponsavel == null ||
                      tarefa.responsavel == filtroResponsavel;
                }).toList();

                return tarefasFiltradas.isEmpty
                    ? const Center(
                        child: Text(
                          'Não existem tarefas',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tarefasFiltradas.length,
                        itemBuilder: (BuildContext context, int index) {
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
