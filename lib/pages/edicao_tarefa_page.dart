import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class EdicaoTarefaPage extends StatefulWidget {
  final Tarefa tarefa;

  const EdicaoTarefaPage({super.key, required this.tarefa});

  @override
  State<EdicaoTarefaPage> createState() => _EdicaoTarefaPageState();
}

class _EdicaoTarefaPageState extends State<EdicaoTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  late String nome;
  late String descricao;

  @override
  void initState() {
    super.initState();
    nome = widget.tarefa.nome;
    descricao = widget.tarefa.descricao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
                onSaved: (value) {
                  nome = value!;
                },
              ),
              TextFormField(
                initialValue: descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                onSaved: (value) {
                  descricao = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      widget.tarefa.nome = nome;
                      widget.tarefa.descricao = descricao;
                    });
                    Navigator.pop(context);
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
