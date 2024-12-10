import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/casas_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContaPage extends StatelessWidget {
  const ContaPage({super.key});

  Future<String> _obterUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Usuário não encontrado";

    try {
      // Acessar a coleção "usuarios" no Firestore para buscar o username
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      return doc.data()?['username'] ?? "Username não disponível";
    } catch (e) {
      return "Erro ao carregar username";
    }
  }

  @override
  Widget build(BuildContext context) {
    final casasRepository =
        Provider.of<CasasRepository>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    final email = user?.email ?? "Email não disponível";
    final casa = casasRepository.casaAtual?.nome ?? "Nenhuma casa associada";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minha Conta"),
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informações da Conta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _obterUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text("Carregando username..."),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    leading: Icon(Icons.error, color: Colors.red),
                    title: Text("Erro ao carregar username"),
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Username"),
                    subtitle: Text(snapshot.data ?? "Username não disponível"),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(email),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Casa"),
              subtitle: Text(casa),
            ),
          ],
        ),
      ),
    );
  }
}
