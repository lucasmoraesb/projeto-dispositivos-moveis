import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/databases/db_firestore.dart';
import 'package:projeto_dispositivos_moveis/models/casa.dart';
import 'package:projeto_dispositivos_moveis/services/auth_service.dart';
import '../models/tarefa.dart';

class TarefasRepository extends ChangeNotifier {
  final List<Tarefa> _lista = [];
  late FirebaseFirestore db;
  late AuthService auth;

  TarefasRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  UnmodifiableListView<Tarefa> get lista => UnmodifiableListView(_lista);

  // Criar casa
  // Método para criar uma nova casa
  criarTarefa(String senhaCasa, Tarefa tarefa) async {
    try {
      // Busca o documento da casa correspondente à senha fornecida
      final querySnapshot = await db
          .collection('casas')
          .where('senha', isEqualTo: senhaCasa)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Nenhuma casa encontrada com a senha fornecida.");
      }

      // Obtém o ID da casa
      final casaId = querySnapshot.docs.first.id;

      // Adiciona a tarefa à subcoleção "tarefas" da casa encontrada
      final tarefaRef =
          await db.collection('casas').doc(casaId).collection('tarefas').add({
        'nome': tarefa.nome,
        'data': tarefa.data.toIso8601String(),
        'descricao': tarefa.descricao,
        'responsavel': tarefa.responsavel,
        'status': tarefa.status,
      });

      // Atualiza localmente a lista com a nova tarefa
      _lista.add(tarefa);

      notifyListeners();

      print("Tarefa criada com ID: ${tarefaRef.id}");
    } catch (e) {
      print("Erro ao criar a tarefa: $e");
      throw Exception("Erro ao criar a tarefa: $e");
    }
  }

  Stream<List<Tarefa>> getTarefasPorSenhaCasa(String senhaCasa) async* {
    final querySnapshot =
        await db.collection('casas').where('senha', isEqualTo: senhaCasa).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("Nenhuma casa encontrada com a senha fornecida.");
    }

    final casaId = querySnapshot.docs.first.id;

    yield* db
        .collection('casas')
        .doc(casaId)
        .collection('tarefas')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Tarefa(
          nome: doc['nome'],
          data: DateTime.parse(doc['data']),
          descricao: doc['descricao'],
          responsavel: doc['responsavel'],
          status: doc['status'],
        );
      }).toList();
    });
  }

  Future<List<Tarefa>> getTarefasDoDia(String senhaCasa) async {
    try {
      final querySnapshot = await db
          .collection('casas')
          .where('senha', isEqualTo: senhaCasa)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Nenhuma casa encontrada com a senha fornecida.");
      }

      final casaId = querySnapshot.docs.first.id;
      final hoje = DateTime.now();
      final inicioDoDia =
          DateTime(hoje.year, hoje.month, hoje.day); // Início do dia
      final fimDoDia = inicioDoDia.add(const Duration(days: 1)); // Fim do dia

      final tarefasSnapshot = await db
          .collection('casas')
          .doc(casaId)
          .collection('tarefas')
          .where('data', isGreaterThanOrEqualTo: inicioDoDia.toIso8601String())
          .where('data', isLessThan: fimDoDia.toIso8601String())
          .get();

      return tarefasSnapshot.docs.map((doc) {
        return Tarefa(
          nome: doc['nome'],
          data: DateTime.parse(doc['data']),
          descricao: doc['descricao'],
          responsavel: doc['responsavel'],
          status: doc['status'],
        );
      }).toList();
    } catch (e) {
      print("Erro ao obter as tarefas do dia: $e");
      throw Exception("Erro ao obter as tarefas do dia: $e");
    }
  }

  Future<void> removerTarefa(String senhaCasa, Tarefa tarefa) async {
    try {
      final querySnapshot = await db
          .collection('casas')
          .where('senha', isEqualTo: senhaCasa)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Nenhuma casa encontrada com a senha fornecida.");
      }

      final casaId = querySnapshot.docs.first.id;

      // Busca o documento da tarefa com base nos campos correspondentes
      final tarefasSnapshot = await db
          .collection('casas')
          .doc(casaId)
          .collection('tarefas')
          .where('nome', isEqualTo: tarefa.nome)
          .where('data', isEqualTo: tarefa.data.toIso8601String())
          .get();

      if (tarefasSnapshot.docs.isNotEmpty) {
        await tarefasSnapshot.docs.first.reference.delete();
        _lista.remove(tarefa); // Remove localmente
        notifyListeners();
      }
    } catch (e) {
      print("Erro ao remover a tarefa: $e");
      throw Exception("Erro ao remover a tarefa: $e");
    }
  }

  Future<void> concluirTarefaUpdate(
      String senhaCasa, Tarefa tarefa, String novaDescricao) async {
    try {
      // Busca a casa pelo código da senha
      final querySnapshot = await db
          .collection('casas')
          .where('senha', isEqualTo: senhaCasa)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Nenhuma casa encontrada com a senha fornecida.");
      }

      final casaId = querySnapshot.docs.first.id;

      // Busca a tarefa correspondente
      final tarefasSnapshot = await db
          .collection('casas')
          .doc(casaId)
          .collection('tarefas')
          .where('nome', isEqualTo: tarefa.nome)
          .where('data', isEqualTo: tarefa.data.toIso8601String())
          .get();

      if (tarefasSnapshot.docs.isNotEmpty) {
        // Atualiza a tarefa no Firestore
        await tarefasSnapshot.docs.first.reference.update({
          'status': 'Concluído',
          'descricao': novaDescricao,
        });
        notifyListeners();
      } else {
        throw Exception("Tarefa não encontrada para atualização.");
      }
    } catch (e) {
      print("Erro ao concluir a tarefa: $e");
      throw Exception("Erro ao concluir a tarefa: $e");
    }
  }

  // Método para remover uma tarefa da lista
  remove(Tarefa tarefa) {
    _lista.remove(tarefa);
    notifyListeners();
  }
}
