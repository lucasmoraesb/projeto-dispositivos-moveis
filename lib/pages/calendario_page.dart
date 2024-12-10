import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../repositories/tarefas_repository.dart';
import '../widgets/calendario_card.dart';
import 'configuracoes_page.dart';
import '../models/tarefa.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../repositories/casas_repository.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  late String senhaCasa;
  Map<DateTime, int> tarefasCount =
      {}; // Armazenar a contagem de tarefas por dia

  @override
  void initState() {
    super.initState();
    // Obtenha a senha da casa no initState
    final casasRepo = Provider.of<CasasRepository>(context, listen: false);
    senhaCasa = casasRepo.senhaCasaAtual;
  }

  // Método para obter a contagem de tarefas para um dia específico
  Future<int> _getTarefasCountForDay(DateTime day) async {
    final tarefasRepository = TarefasRepository(
        auth: AuthService(),
        casasRepository: CasasRepository(auth: AuthService()));
    final todasTarefas =
        await tarefasRepository.getTarefasPorSenhaCasa(senhaCasa).first;
    return todasTarefas.where((tarefa) {
      return tarefa.data.year == day.year &&
          tarefa.data.month == day.month &&
          tarefa.data.day == day.day;
    }).length;
  }

  mostrarConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfiguracoesPage(),
      ),
    );
  }

  // Método para atualizar a contagem de tarefas para o mês atual
  /* void _updateTarefasCount() async {
    for (var i = 0; i < 31; i++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, i + 1);
      if (date.month == _focusedDay.month) {
        final count = await _getTarefasCountForDay(date);
        if (mounted) {
          // Verifique se o widget ainda está montado
          setState(() {
            tarefasCount[date] = count;
          });
        }
      }
    }
  } */

  @override
  Widget build(BuildContext context) {
    // Atualizar a contagem de tarefas quando o mês mudar
    //_updateTarefasCount();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        centerTitle: true,
        title: const Text("Selecione uma Data"),
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 25,
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFFFFF),
        child: ListView(
          children: [
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.settings),
              ),
              title: const Text('Configurações'),
              onTap: () {
                mostrarConfiguracoes();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            locale: 'pt_BR',
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = selectedDay;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarioCard(
                    selectedDate: selectedDay,
                  ),
                ),
              );
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return FutureBuilder<int>(
                  future: _getTarefasCountForDay(
                      day), // Obtém o número de tarefas para o dia
                  builder: (context, snapshot) {
                    final tarefasCountForDay =
                        snapshot.data ?? 0; // Default para 0 tarefas
                    return Stack(
                      alignment: Alignment.center, // Centraliza os widgets
                      children: [
                        // Texto central com o número do dia
                        Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        // Indicador vermelho com a quantidade de tarefas
                        if (tarefasCountForDay > 0)
                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$tarefasCountForDay',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
