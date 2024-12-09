import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../repositories/casas_repository.dart'; // Importando o CasasRepository

class NovaTarefaPage extends StatefulWidget {
  const NovaTarefaPage({super.key});

  @override
  State<NovaTarefaPage> createState() => _NovaTarefaPageState();
}

class _NovaTarefaPageState extends State<NovaTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  String? _responsavel;
  DateTime? _dataSelecionada;

  @override
  Widget build(BuildContext context) {
    final casasRepo = Provider.of<CasasRepository>(context);
    final senhaCasa = casasRepo.senhaCasaAtual;

    // Obter os membros da casa
    final membros = casasRepo.obterMembrosDaCasa();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Tarefa'),
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
                    return 'Por favor, insira o nome da tarefa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              // Dropdown para selecionar o responsável
              DropdownButtonFormField<String>(
                value: _responsavel,
                decoration: const InputDecoration(labelText: 'Responsável'),
                items: membros
                    .map((membro) => DropdownMenuItem<String>(
                          value: membro,
                          child: Text(membro),
                        ))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    _responsavel = valor;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o responsável';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final dataSelecionada = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (dataSelecionada != null) {
                    setState(() {
                      _dataSelecionada = dataSelecionada;
                    });
                  }
                },
                child: Text(
                  _dataSelecionada == null
                      ? 'Selecionar Data'
                      : 'Data: ${_dataSelecionada!.toLocal()}',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _dataSelecionada != null) {
                    final novaTarefa = Tarefa(
                      nome: _nomeController.text,
                      data: _dataSelecionada!,
                      descricao: _descricaoController.text,
                      responsavel: _responsavel ?? '',
                      status: 'Não concluída',
                    );

                    final tarefasRepo =
                        Provider.of<TarefasRepository>(context, listen: false);

                    await tarefasRepo.criarTarefa(senhaCasa, novaTarefa);

                    Navigator.pop(context, novaTarefa);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
