import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';

class NovaTarefaPage extends StatefulWidget {
  @override
  _NovaTarefaPageState createState() => _NovaTarefaPageState();
}

class _NovaTarefaPageState extends State<NovaTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime? _dataSelecionada;

  _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        title: Text('Nova Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _dataSelecionada == null
                        ? 'Nenhuma data selecionada'
                        : 'Data: ${_dataSelecionada!.toLocal()}'.split(' ')[0],
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _selecionarData(context),
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _dataSelecionada != null) {
                    final novaTarefa = Tarefa(
                      nome: _nomeController.text,
                      data: _dataSelecionada!,
                      descricao: _descricaoController.text,
                    );
                    TarefasRepository.tabela.add(novaTarefa);
                    Navigator.pop(context);
                  }
                },
                child: Text('Criar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
