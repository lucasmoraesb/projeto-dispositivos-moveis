import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/pages/nova_casa_page.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
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

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: OutlinedButton(
                onPressed: () async {
                  await context.read<AuthService>().logout();
                  if (auth.usuario == null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
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
                    )
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: OutlinedButton(
                onPressed: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const NovaCasaPage()),
                  );
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Criar Casa',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
