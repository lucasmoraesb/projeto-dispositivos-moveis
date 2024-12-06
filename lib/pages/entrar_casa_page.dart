import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/paginas_controller.dart';
import '../repositories/casas_repository.dart';
import '../services/auth_service.dart';

class EntrarCasaPage extends StatefulWidget {
  const EntrarCasaPage({super.key});

  @override
  _EntrarCasaPageState createState() => _EntrarCasaPageState();
}

class _EntrarCasaPageState extends State<EntrarCasaPage> {
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final casasRepository =
        Provider.of<CasasRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar em uma Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha da Casa'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a senha da casa';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_senhaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, insira a senha'),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      // Tenta adicionar o usuário à casa
                      bool entrou = await casasRepository
                          .entrarEmCasa(_senhaController.text);

                      setState(() {
                        _isLoading = false;
                      });

                      if (entrou) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Você entrou na casa com sucesso!'),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaginasController()),
                        ); // Navega de volta à tela anterior
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Senha incorreta. Tente novamente.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Entrar na Casa'),
                  ),
          ],
        ),
      ),
    );
  }
}
