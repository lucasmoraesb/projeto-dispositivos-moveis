import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';

class NovaTarefaPage extends StatefulWidget {
  final Tarefa? tarefa; // Tarefa opcional para edição

  const NovaTarefaPage({super.key, this.tarefa}); // Recebe a tarefa opcional

  @override
  _NovaTarefaPageState createState() => _NovaTarefaPageState();
}

class _NovaTarefaPageState extends State<NovaTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    // Se uma tarefa for passada, preencha os campos
    if (widget.tarefa != null) {
      _nomeController.text = widget.tarefa!.nome;
      _descricaoController.text = widget.tarefa!.descricao;
      _dataSelecionada = widget.tarefa!.data;
    }
  }

  _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa != null ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _dataSelecionada == null
                        ? 'Nenhuma data selecionada'
                        : 'Data: ${_dataSelecionada!.toLocal()}'.split(' ')[0],
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _selecionarData(context),
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _dataSelecionada != null) {
                    final novaTarefa = Tarefa(
                      nome: _nomeController.text,
                      data: _dataSelecionada!,
                      descricao: _descricaoController.text,
                    );

                    if (widget.tarefa != null) {
                      // Se uma tarefa foi passada, atualiza a tarefa existente
                      int index =
                          TarefasRepository.tabela.indexOf(widget.tarefa!);
                      TarefasRepository.tabela[index] =
                          novaTarefa; // Atualiza a tarefa
                    } else {
                      // Caso contrário, adiciona uma nova tarefa
                      TarefasRepository.tabela.add(novaTarefa);
                    }

                    Navigator.pop(
                        context, novaTarefa); // Retorna a nova tarefa editada
                  }
                },
                child: Text(
                    widget.tarefa != null ? 'Salvar Tarefa' : 'Criar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
