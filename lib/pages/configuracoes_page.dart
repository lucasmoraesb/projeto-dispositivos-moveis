import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/pages/acao_casa_page.dart';
import 'package:projeto_dispositivos_moveis/pages/nova_casa_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../repositories/casas_repository.dart';
import 'login_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);
    CasasRepository casasRepository =
        Provider.of<CasasRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        centerTitle: true,
        title: const Text('Configurações'),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 25,
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: OutlinedButton(
              onPressed: () async {
                await context.read<AuthService>().logout();
                if (auth.usuario == null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: OutlinedButton(
              onPressed: () async {
                bool sucesso = await casasRepository.sairDaCasa();
                if (sucesso) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const AcaoCasaPage()),
                  );
                  // Se a operação foi bem-sucedida, mostramos uma mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Você saiu da casa com sucesso.')),
                  );
                } else {
                  // Caso contrário, mostramos uma mensagem de erro
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao sair da casa.')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Sair da Casa',
                      style: TextStyle(fontSize: 18),
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
