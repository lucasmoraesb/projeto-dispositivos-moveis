import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/databases/db_firestore.dart';
import 'package:projeto_dispositivos_moveis/models/casa.dart';
import 'package:projeto_dispositivos_moveis/services/auth_service.dart';
import '../models/tarefa.dart';

class CasasRepository extends ChangeNotifier {
  final List<Casa> _lista = [];
  late FirebaseFirestore db;
  late AuthService auth;

  CasasRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    _authCheckCasas();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  void _authCheckCasas() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await _syncCasas();
        print("Casas:$_lista");
      } else {
        _lista.clear();
        notifyListeners();
      }
    });
  }

  Future<void> _syncCasas() async {
    try {
      final casasSnapshot = await db.collection('casas').get();
      Casa? casaAtual; // Permite que casaAtual seja nula

      // Obtém o usuário logado
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("Erro: usuário não logado.");
        return; // Retorna caso não tenha usuário logado
      }

      // Busca o nome de usuário na coleção 'usuarios'
      final usuarioSnapshot =
          await db.collection('usuarios').doc(currentUser.uid).get();
      String? nomeUsuario =
          usuarioSnapshot.data()?['username']; // Campo 'username'

      if (nomeUsuario == null) {
        print("Erro: nome de usuário não encontrado.");
        return; // Retorna caso o username não esteja no banco de dados
      }

      // Busca as casas e verifica se o usuário está em alguma delas
      for (var doc in casasSnapshot.docs) {
        final data = doc.data();
        final casa = Casa(
          nome: data['nome'],
          criador: data['criador'],
          membros: List<String>.from(data['membros'] ?? []),
          senha: data['senha'],
        );

        _lista.add(casa);

        if (casa.membros.contains(nomeUsuario)) {
          casaAtual = casa; // Armazena a casa em que o usuário está
          break; // Sai do loop após encontrar a casa correta
        }
      }

      if (casaAtual != null) {
        // Caso o usuário esteja em uma casa, define a senhaCasaAtual
        senhaCasaAtual = casaAtual.senha;
        print("Usuário está na casa: ${casaAtual.nome}");
      } else {
        print("Usuário não está em nenhuma casa.");
      }

      notifyListeners(); // Notifica a UI
      print("SUCESSO");
    } catch (e) {
      print("Erro ao sincronizar casas: $e");
    }
  }

  String _senhaCasaAtual = '';

  String get senhaCasaAtual => _senhaCasaAtual;

  set senhaCasaAtual(String senha) {
    _senhaCasaAtual = senha;
    notifyListeners();
  }

  UnmodifiableListView<Casa> get lista => UnmodifiableListView(_lista);

  // Criar casa
  criarCasa(Casa casa) async {
    _lista.add(casa);

    try {
      await db.collection('casas').add({
        'nome': casa.nome,
        'criador': casa.criador,
        'membros': casa.membros,
        'senha': casa.senha,
      });
      _senhaCasaAtual = casa.senha;
      notifyListeners();
    } catch (e) {
      print("Erro ao criar a casa: $e");
    }
  }

  // Método para obter os membros da casa com base na senha
  List<String> obterMembrosDaCasa() {
    final casaAtual = _lista.firstWhere(
      (casa) => casa.senha == _senhaCasaAtual,
      orElse: () => Casa(senha: '', nome: '', criador: '', membros: []),
    );
    return casaAtual.membros;
  }

  // Método para o usuário entrar em uma casa
  // Método para o usuário entrar em uma casa
  entrarEmCasa(String senhaCasa) async {
    try {
      // Obter o username do usuário logado
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(auth.usuario!.uid)
          .get();
      final usernameLogado = doc.data()?['username'];

      if (usernameLogado == null) {
        return false;
      }

      // Obter todas as casas do Firestore
      final casasSnapshot =
          await FirebaseFirestore.instance.collection('casas').get();

      for (var casaDoc in casasSnapshot.docs) {
        final casaData = casaDoc.data();
        final casaSenha = casaData['senha'];

        // Verifica se a senha corresponde à casa
        if (casaSenha == senhaCasa) {
          _senhaCasaAtual = senhaCasa;
          notifyListeners();

          // Atualiza os membros no Firestore
          await FirebaseFirestore.instance
              .collection('casas')
              .doc(casaDoc.id)
              .update({
            'membros': FieldValue.arrayUnion([usernameLogado]),
          });

          // Atualiza a lista localmente
          final casaIndex =
              _lista.indexWhere((casa) => casa.senha == senhaCasa);

          if (casaIndex != -1) {
            // Atualiza a casa existente
            _lista[casaIndex].membros.add(usernameLogado);
          } else {
            // Exibe um Snackbar informando o erro
            print(_lista);
            print("username ta zuado");
            return false;
          }

          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Erro ao tentar entrar na casa: $e');
      return false;
    }
  }

  // Método para remover uma tarefa da lista
  remove(Tarefa tarefa) {
    _lista.remove(tarefa);
    notifyListeners();
  }
}
