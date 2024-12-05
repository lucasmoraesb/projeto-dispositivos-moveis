import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../repositories/tarefas_repository.dart';
import '../widgets/calendario_card.dart';
import 'configuracoes_page.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();

  int _getTarefasCountForDay(DateTime day) {
    return TarefasRepository.tabela.where((tarefa) {
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
                padding: EdgeInsets.only(
                    right: 8.0), // Adiciona um padding à direita do ícone
                child: Icon(Icons.settings), // Ícone de engrenagem
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
            focusedDay: _focusedDay, // Use a data focada
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay =
                    selectedDay; // Atualize o mês focado para a data selecionada
              });
              // Navegar para a DisplayDateScreen ao selecionar uma data
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
