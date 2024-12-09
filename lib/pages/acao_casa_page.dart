import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'entrar_casa_page.dart';
import 'nova_casa_page.dart';

class AcaoCasaPage extends StatelessWidget {
  const AcaoCasaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher ou Criar Casa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Você pode criar uma nova casa ou entrar em uma existente.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de criação de casa
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NovaCasaPage()),
                );
              },
              child: const Text('Criar Nova Casa'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de entrada na casa existente
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EntrarCasaPage()),
                );
              },
              child: const Text('Entrar em Casa Existente'),
            ),
          ],
        ),
      ),
    );
  }
}
