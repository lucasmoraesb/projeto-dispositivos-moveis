import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/controllers/paginas_controller.dart';
import 'package:projeto_dispositivos_moveis/pages/acao_casa_page.dart';
import 'package:projeto_dispositivos_moveis/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'nova_casa_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final senha = TextEditingController();
  final usernameController = TextEditingController();

  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool acao) {
    setState(() {
      isLogin = acao;
      if (isLogin) {
        titulo = 'Bem-vindo';
        actionButton = 'Login';
        toggleButton = 'Ainda não tem conta? Cadastre-se agora.';
      } else {
        titulo = 'Crie sua conta';
        actionButton = 'Cadastrar';
        toggleButton = 'Voltar ao login.';
      }
    });
  }

  login() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => loading = true);
    try {
      await auth.login(email.text, senha.text, usernameController.text);

      if (auth.usuario != null) {
        // Acessa o documento do usuário logado
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(auth.usuario!.uid)
            .get();
        final data = doc.data();
        final username = data?['username'];

        if (username != null) {
          // Busca em todas as casas para verificar se o usuário já é membro
          final casasSnapshot =
              await FirebaseFirestore.instance.collection('casas').get();

          bool usuarioEmCasa = false;

          for (var casaDoc in casasSnapshot.docs) {
            final casaData = casaDoc.data();
            final membros = List<String>.from(casaData['membros'] ?? []);

            if (membros.contains(username)) {
              usuarioEmCasa = true;
              break;
            }
          }

          if (usuarioEmCasa) {
            // Usuário já pertence a uma casa, redireciona para PaginasController
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const PaginasController()),
              );
            }
          } else {
            // Usuário não pertence a nenhuma casa, redireciona para AcaoCasaPage
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AcaoCasaPage()),
              );
            }
          }
        } else {
          if (mounted) {
            setState(() => loading = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário ainda não cadastrado.')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  registrar() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => loading = true);
    try {
      await auth.registrar(email.text, senha.text, usernameController.text);

      if (auth.usuario != null) {
        // Acessa o documento do usuário registrado
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(auth.usuario!.uid)
            .get();
        final data = doc.data();
        final username = data?['username'];

        if (username != null) {
          // Busca em todas as casas para verificar se o usuário já é membro
          final casasSnapshot =
              await FirebaseFirestore.instance.collection('casas').get();

          bool usuarioEmCasa = false;

          for (var casaDoc in casasSnapshot.docs) {
            final casaData = casaDoc.data();
            final membros = List<String>.from(casaData['membros'] ?? []);

            if (membros.contains(username)) {
              usuarioEmCasa = true;
              break;
            }
          }

          if (usuarioEmCasa) {
            // Usuário já pertence a uma casa, redireciona para PaginasController
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const PaginasController()),
              );
            }
          } else {
            // Usuário não pertence a nenhuma casa, redireciona para AcaoCasaPage
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AcaoCasaPage()),
              );
            }
          }
        } else {
          throw Exception('Username não encontrado para o usuário atual.');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (!isLogin && (value == null || value.isEmpty)) {
                          return 'Informe um username!';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextFormField(
                        controller: email,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Informe o email corretamente!';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      child: TextFormField(
                        controller: senha,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Senha',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Informe sua senha!';
                          } else if (value.length < 6) {
                            return 'Sua senha deve ter no mínimo 6 caracteres';
                          }
                          return null;
                        },
                      )),
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (isLogin) {
                              login();
                            } else {
                              registrar();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (loading)
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ]
                              : [
                                  const Icon(Icons.check),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      actionButton,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  )
                                ],
                        ),
                      )),
                  TextButton(
                      onPressed: () => setFormAction(!isLogin),
                      child: Text(toggleButton))
                ],
              ),
            )),
      ),
    );
  }
}
