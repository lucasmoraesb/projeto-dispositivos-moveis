import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/repositories/casas_repository.dart';
import 'package:projeto_dispositivos_moveis/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../models/casa.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';

class NovaCasaPage extends StatefulWidget {
  const NovaCasaPage({super.key});

  @override
  _NovaCasaPageState createState() => _NovaCasaPageState();
}

class _NovaCasaPageState extends State<NovaCasaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  late AuthService auth;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Casa'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final casasRepository =
                        Provider.of<CasasRepository>(context, listen: false);

                    // Recupera o username diretamente do AuthService
                    final doc = await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(auth.usuario!.uid)
                        .get();
                    final username = doc.data()?['username'];

                    if (username == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Erro ao recuperar o username.')),
                      );
                      return;
                    }

                    casasRepository.criarCasa(
                      Casa(
                        nome: _nomeController.text,
                        criador: username, // Passa o username como criador
                        membros: [
                          username
                        ], // Inclui o username na lista de membros
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Criar Casa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
