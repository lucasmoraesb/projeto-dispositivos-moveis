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

  criarCasa(Casa casa) async {
    _lista.add(casa);
    await db.collection('usuarios/${auth.usuario!.uid}/casa').doc().set({
      'casa': casa.nome,
      'criador': casa.criador,
      'membros': casa.membros,
    });
    notifyListeners();
  }

  /* sortData() {
    return _lista.sort((Tarefa a, Tarefa b) => a.data.compareTo(b.data));
  } */

  remove(Tarefa tarefa) {
    _lista.remove(tarefa);
    notifyListeners();
  }

  /* sortNome() {
    return _lista.sort((Tarefa a, Tarefa b) => a.nome.compareTo(b.nome));
  } */
}
