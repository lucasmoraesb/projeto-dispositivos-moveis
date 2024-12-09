import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../repositories/tarefas_repository.dart';
import '../widgets/calendario_card.dart';
import '../models/tarefa.dart';
import 'configuracoes_page.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now(); // Mantenha o estado do mês focado

  int _getTarefasCountForDay(DateTime day) {
    return TarefasRepository.tabela.where((tarefa) {
      return tarefa.data.year == day.year &&
          tarefa.data.month == day.month &&
          tarefa.data.day == day.day;
    }).length;
  }

  List<Tarefa> _getTarefasPassadas() {
    return TarefasRepository.tabela
        .where((tarefa) => tarefa.data.isBefore(DateTime.now()))
        .toList();
  }

  List<Tarefa> _getTarefasPendentes() {
    return TarefasRepository.tabela
        .where((tarefa) => !tarefa.data.isBefore(DateTime.now()))
        .toList();
  }

  mostrarConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfiguracoesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                final tarefasCount = _getTarefasCountForDay(day);
                return Stack(
                  children: [
                    Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    if (tarefasCount > 0)
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
                            '$tarefasCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    Positioned(
                      left: 1,
                      top: 1,
                      child: tarefasCount == 0
                          ? const Icon(
                              Icons.add_task,
                              size: 12,
                              color: Colors.green,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tarefas Passadas:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._getTarefasPassadas().map((tarefa) => Card(
                          color: Colors.red[100],
                          elevation: 3,
                          child: ListTile(
                            leading:
                                const Icon(Icons.history, color: Colors.red),
                            title: Text(
                              tarefa.nome,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900],
                              ),
                            ),
                            subtitle: Text(
                              "${tarefa.data.day}/${tarefa.data.month}/${tarefa.data.year}",
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        )),
                    const SizedBox(height: 16),
                    const Text(
                      "Tarefas Pendentes:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._getTarefasPendentes().map((tarefa) => Card(
                          color: Colors.green[100],
                          elevation: 3,
                          child: ListTile(
                            leading:
                                const Icon(Icons.pending, color: Colors.green),
                            title: Text(
                              tarefa.nome,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            subtitle: Text(
                              "${tarefa.data.day}/${tarefa.data.month}/${tarefa.data.year}",
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
