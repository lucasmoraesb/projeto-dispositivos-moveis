import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tarefas_favoritas_repository.dart';
import '../models/tarefa.dart';
import '../widgets/tarefa_card.dart';
import '../pages/tarefas_descricao_page.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({super.key});

  @override
  State<FavoritasPage> createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  List<Tarefa> selecionadas = [];

  // Função para excluir tarefas selecionadas da lista de favoritas
  excluirTarefasSelecionadas() {
    setState(() {
      final favoritas =
          Provider.of<TarefasFavoritasRepository>(context, listen: false);
      for (var tarefa in selecionadas) {
        favoritas.remove(tarefa); // Remove da lista de favoritas
      }
      selecionadas.clear(); // Limpa a lista de selecionadas
    });
  }

  // Função para mostrar o alerta de confirmação de exclusão
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

  mostrarDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarefasDescricaoPage(tarefa: tarefa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Tarefas Favoritas'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Consumer<TarefasFavoritasRepository>(
          builder: (context, favoritas, child) {
            return favoritas.lista.isEmpty
                ? const ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Sem tarefas favoritadas'),
                  )
                : ListView.builder(
                    itemCount: favoritas.lista.length,
                    itemBuilder: (_, index) {
                      final tarefa = favoritas.lista[index];
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
                          excluirTarefasSelecionadas();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.delete),
              label: const Text(
                'Remover',
                style: TextStyle(
                  letterSpacing: 0,
                ),
              ),
              onPressed: () {
                if (selecionadas.isNotEmpty) {
                  // Chama o diálogo de confirmação
                  showAlertDialog2(context, selecionadas, () {
                    excluirTarefasSelecionadas();

                    // Exibir mensagem com o número de tarefas removidas
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tarefa(s) removida(s) com sucesso!',
                        ),
                      ),
                    );
                  });
                }
              },
            )
          : const SizedBox(
              width:
                  0), // Se não houver tarefas selecionadas, não exibe o botão
    );
  }
}
