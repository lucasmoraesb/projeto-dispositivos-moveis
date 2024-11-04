import 'package:flutter/material.dart';
import '../models/tarefa.dart';

class TarefasDescricaoPage extends StatefulWidget {
  final Tarefa tarefa;

  const TarefasDescricaoPage({super.key, required this.tarefa});

  @override
  State<TarefasDescricaoPage> createState() => _TarefasDescricaoPageState();
}

class _TarefasDescricaoPageState extends State<TarefasDescricaoPage> {
  final _form = GlobalKey<FormState>();
  final _valorDescricao = TextEditingController();
  //final _valorData = TextEditingController();

  concluirTarefa() {
    if (_form.currentState!.validate()) {
      // Mudar status para completo

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa completada com sucesso')));
    }
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
          Text(widget.tarefa.data.toString()),
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
                  return 'forme o Texto ##TESTE##';
                } else {
                  return null;
                }
              },
            ),
          ),
          /*Form(
            key: _form,
            child: TextFormField(
              controller: _valorData,
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
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),*/ // Insercao somente de numeros
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(top: 24),
            child: ElevatedButton(
              onPressed: concluirTarefa,
              child: Row(
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
        ],
      ),
    );
  }
}
