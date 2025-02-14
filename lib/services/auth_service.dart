import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Recupera o documento do Firestore
        final doc = await _firestore.collection('usuarios').doc(user.uid).get();
        final data = doc.data();

        if (data != null) {
          print(
              'Username: ${data['username']}'); // Exemplo de como usar o username
        }

        usuario = user;
      } else {
        usuario = null;
      }
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  registrar(String email, String senha, String username) async {
    try {
      // Verifica se o username já está em uso
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw AuthException('Este username já está em uso.');
      }

      // Cria o usuário
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Salva o username no Firestore
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _getUser(); // Atualiza o estado local
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Esse email já está cadastrado');
      }
    }
  }

  login(String email, String senha, String username) async {
    try {
      // Tenta fazer o login com email e senha
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();

      // Verifica se o usuário foi autenticado
      if (usuario != null) {
        // Recupera o documento do Firestore para o usuário logado
        final doc =
            await _firestore.collection('usuarios').doc(usuario!.uid).get();
        final data = doc.data();

        if (data != null) {
          final storedUsername = data['username'];

          // Verifica se o username inserido corresponde ao registrado no Firestore
          if (storedUsername != username) {
            throw AuthException(
                'O username inserido não corresponde ao registrado.');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Tratar erros de autenticação do Firebase
      if (e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente.');
      } else if (e.code == 'invalid-credential') {
        throw AuthException('Email ou senha incorretos. Tente novamente.');
      } else {
        // Tratamento genérico para qualquer outro erro do Firebase
        throw AuthException(e.message ?? 'Ocorreu um erro inesperado.');
      }
    } catch (e) {
      // Captura qualquer outro tipo de exceção
      if (usuario != null) {
        // Recupera o documento do Firestore para o usuário logado
        final doc =
            await _firestore.collection('usuarios').doc(usuario!.uid).get();
        final data = doc.data();

        if (data != null) {
          final storedUsername = data['username'];

          // Verifica se o username inserido corresponde ao registrado no Firestore
          if (storedUsername != username) {
            throw AuthException('Username incorreto. Tente novamente.');
          }
        }
      }
      throw AuthException('Erro desconhecido: $e');
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
