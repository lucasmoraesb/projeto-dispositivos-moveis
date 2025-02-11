import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projeto_dispositivos_moveis/repositories/casas_repository.dart';
import 'package:projeto_dispositivos_moveis/repositories/tarefas_repository.dart';
import 'package:projeto_dispositivos_moveis/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'repositories/tarefas_favoritas_repository.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  NotificationService.initialize();

  // Inicializa a formatação da localidade para pt_BR
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthService()),
          ChangeNotifierProvider(
              create: (context) => CasasRepository(
                    auth: context.read<AuthService>(),
                  )),
          ChangeNotifierProvider(
              create: (context) => TarefasRepository(
                    auth: context.read<AuthService>(),
                    casasRepository: context.read<CasasRepository>(),
                  )),
          ChangeNotifierProvider(
              create: (context) => TarefasFavoritasRepository()),
        ],
        child: const App(),
      ),
    );
  });
}
