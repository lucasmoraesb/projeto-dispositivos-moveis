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

  UnmodifiableListView<Casa> get lista => UnmodifiableListView(_lista);

  // Criar casa
  // Método para criar uma nova casa
  criarCasa(Casa casa) async {
    _lista.add(casa);

    try {
      // Criar um documento para a casa dentro da coleção global "casas"
      await db.collection('casas').add({
        'nome': casa.nome, // Nome da casa
        'criador': casa.criador, // Nome do criador da casa
        'membros': casa
            .membros, // Lista de membros da casa (inicialmente com o criador)
        'senha': casa.senha, // Senha da casa
      });

      // Após criar a casa, você pode adicionar o criador à lista de membros (se não foi feito)
      // No caso do criador, ele já estará na lista de membros devido ao campo casa.membros
      notifyListeners();
    } catch (e) {
      print("Erro ao criar a casa: $e");
    }
  }

  // Método para o usuário entrar em uma casa usando a senha
  entrarEmCasa(String senhaCasa) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(auth.usuario!.uid)
          .get();
      final usernameLogado = doc.data()?['username'];

      if (usernameLogado == null) {
        // Se o username do usuário logado não for encontrado
        return false;
      }

      // Busca todas as casas na coleção global "casas"
      final casasSnapshot =
          await FirebaseFirestore.instance.collection('casas').get();

      // Percorre todas as casas para verificar se a senha da casa bate
      for (var casaDoc in casasSnapshot.docs) {
        final casaData = casaDoc.data();
        final casaSenha = casaData['senha'];

        if (casaSenha == senhaCasa) {
          // Se a senha corresponder, o usuário entra na casa
          await FirebaseFirestore.instance
              .collection('casas')
              .doc(casaDoc.id)
              .update({
            'membros': FieldValue.arrayUnion(
                [usernameLogado]), // Adiciona o username na lista de membros
          });

          // Ação concluída com sucesso
          return true;
        }
      }

      // Caso a senha não seja encontrada em nenhuma casa
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
