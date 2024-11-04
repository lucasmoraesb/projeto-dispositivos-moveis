import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import 'package:intl/intl.dart';

class TarefasDescricaoPage extends StatefulWidget {
  final Tarefa tarefa;

  const TarefasDescricaoPage({super.key, required this.tarefa});

  @override
  State<TarefasDescricaoPage> createState() => _TarefasDescricaoPageState();
}

class _TarefasDescricaoPageState extends State<TarefasDescricaoPage> {
  final _form = GlobalKey<FormState>();
  final _valorDescricao = TextEditingController();

  concluirTarefa() {
    if (_form.currentState!.validate()) {
      setState(() {
        widget.tarefa.status = 'Concluído';
        widget.tarefa.descricao = _valorDescricao.text;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa completada com sucesso')));
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
      ),
      body: Column(
        children: [
          Text(widget.tarefa.descricao),
          Text(
            DateFormat('dd/MM/yyyy').format(widget.tarefa.data),
          ),
          Form(
            key: _form,
            child: TextFormField(
              controller: _valorDescricao,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Descrição',
                prefixIcon: Icon(Icons.keyboard),
                suffix: Text(
                  'sufixo',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Escreva algum texto';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(widget.tarefa.data)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
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
          ), // Insercao somente de numeros
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
