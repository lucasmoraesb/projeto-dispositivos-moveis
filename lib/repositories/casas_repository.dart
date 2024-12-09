import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  }

  _startFirestore() {
    db = DBFirestore.get();
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
