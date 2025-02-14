import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  static Future<void> showNotificationAtScheduledTime(
      int id, String title, String body, DateTime dateTime) async {
    // Convertendo para o fuso horário de São Paulo
    final scheduledTime =
        tz.TZDateTime.from(dateTime, tz.getLocation('America/Sao_Paulo'));

    // Calcular a diferença entre a hora atual e a hora desejada
    final now = tz.TZDateTime.now(tz.getLocation('America/Sao_Paulo'));
    final difference = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(minutes: 1)).difference(now)
        : scheduledTime.difference(now);

    // Usando a diferença para agendar a notificação
    await Future.delayed(difference, () async {
      await _notificationsPlugin.show(
        id, // ID da notificação
        title, // Título da notificação
        body, // Corpo da notificação
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders', // Canal da notificação
            'Lembretes de Tarefas', // Nome do canal
            importance: Importance.high, // Importância da notificação
            priority: Priority.high, // Prioridade da notificação
          ),
        ),
      );
    });

    print("Notificação agendada para: $scheduledTime");
  }
}
