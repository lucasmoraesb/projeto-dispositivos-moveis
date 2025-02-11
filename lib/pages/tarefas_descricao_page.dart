import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tarefa.dart';
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
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String tarefaId) async {
    if (_image == null) return;
    final storageRef =
        FirebaseStorage.instance.ref().child('tarefas/$tarefaId.jpg');
    await storageRef.putFile(_image!);
    final imageUrl = await storageRef.getDownloadURL();
    // Atualizar a tarefa com a URL da imagem
    final tarefasRepo = Provider.of<TarefasRepository>(context, listen: false);
    final senhaCasa =
        Provider.of<CasasRepository>(context, listen: false).senhaCasaAtual;
    await tarefasRepo.atualizarImagemTarefa(senhaCasa, widget.tarefa, imageUrl);
  }

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

        // Upload da imagem
        await _uploadImage(widget.tarefa.nome);

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
              const SizedBox(height: 20),
              if (_image != null) Image.file(_image!),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tirar Foto'),
                  ),
                  ElevatedButton(
                    onPressed: concluirTarefa,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Concluir Tarefa'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
