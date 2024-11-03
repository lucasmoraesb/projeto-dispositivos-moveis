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
  final _iconeController = TextEditingController();
  final _dataController = TextEditingController();
  final _descricaoController = TextEditingController();

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
                controller: _iconeController,
                decoration: InputDecoration(labelText: 'Ícone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o ícone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(labelText: 'Data (ano-mês-dia)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final novaTarefa = Tarefa(
                      nome: _nomeController.text,
                      icone: _iconeController.text,
                      data: _dataController.text,
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
