import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import 'package:intl/intl.dart';

import '../repositories/casas_repository.dart';
import '../repositories/tarefas_repository.dart';

class TarefasDescricaoPage extends StatefulWidget {
  final Tarefa tarefa;

  const TarefasDescricaoPage({super.key, required this.tarefa});

  @override
  State<TarefasDescricaoPage> createState() => _TarefasDescricaoPageState();
}

class _TarefasDescricaoPageState extends State<TarefasDescricaoPage> {
  final _form = GlobalKey<FormState>();
  final _valorDescricao = TextEditingController();

  concluirTarefa() async {
    if (_form.currentState!.validate()) {
      final tarefasRepo =
          Provider.of<TarefasRepository>(context, listen: false);
      final senhaCasa =
          Provider.of<CasasRepository>(context, listen: false).senhaCasaAtual;

      try {
        // Atualiza no Firestore
        await tarefasRepo.concluirTarefaUpdate(
          senhaCasa,
          widget.tarefa,
          _valorDescricao.text,
        );

        // Atualiza localmente
        setState(() {
          widget.tarefa.status = 'Concluído';
          widget.tarefa.descricao = _valorDescricao.text;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa completada com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  desconcluirTarefa() async {
    if (_form.currentState!.validate()) {
      final tarefasRepo =
          Provider.of<TarefasRepository>(context, listen: false);
      final senhaCasa =
          Provider.of<CasasRepository>(context, listen: false).senhaCasaAtual;

      try {
        // Atualiza no Firestore
        await tarefasRepo.desconcluirTarefaUpdate(
          senhaCasa,
          widget.tarefa,
          _valorDescricao.text,
        );

        // Atualiza localmente
        setState(() {
          widget.tarefa.status = 'Não concluída';
          widget.tarefa.descricao = _valorDescricao.text;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa desconcluida com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  editarTarefa() async {
    if (_form.currentState!.validate()) {
      final tarefasRepo =
          Provider.of<TarefasRepository>(context, listen: false);
      final senhaCasa =
          Provider.of<CasasRepository>(context, listen: false).senhaCasaAtual;

      try {
        // Atualiza no Firestore
        await tarefasRepo.concluirTarefaUpdate(
          senhaCasa,
          widget.tarefa,
          _valorDescricao.text,
        );

        // Atualiza localmente
        setState(() {
          widget.tarefa.descricao = _valorDescricao.text;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descrição alterada com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Não inicializamos o campo de texto com a descrição da tarefa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa.nome),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 25,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Responsável:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.tarefa.responsavel,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Descrição:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.tarefa.descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(widget.tarefa.data)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (widget.tarefa.status == 'Não concluída') ...[
              Form(
                key: _form,
                child: TextFormField(
                  controller: _valorDescricao,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Descrição da Conclusão',
                    prefixIcon: Icon(Icons.keyboard),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira a descrição para concluir a tarefa';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: concluirTarefa,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Concluir Tarefa',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Form(
                key: _form,
                child: TextFormField(
                  controller: _valorDescricao,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.keyboard),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: editarTarefa,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Atualizar Descrição',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: desconcluirTarefa,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Desconcluir Tarefa',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
