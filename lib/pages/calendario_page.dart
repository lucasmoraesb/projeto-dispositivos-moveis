import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../widgets/tarefa_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now(); // Mantenha o estado do mês focado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecione uma Data")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
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
                  builder: (context) => DisplayDateScreen(
                    selectedDate: selectedDay,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DisplayDateScreen extends StatelessWidget {
  final DateTime selectedDate;

  const DisplayDateScreen({super.key, required this.selectedDate});

  List<Tarefa> _getTarefasForSelectedDate() {
    // Filtra as tarefas pela data selecionada
    return TarefasRepository.tabela.where((tarefa) {
      return tarefa.data.year == selectedDate.year &&
          tarefa.data.month == selectedDate.month &&
          tarefa.data.day == selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as tarefas para a data selecionada
    final tarefas = _getTarefasForSelectedDate();
    final formattedDate =
        DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
      ),
      body: tarefas.isEmpty
          ? const Center(child: Text('Nenhuma tarefa para esta data'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return TarefaCard(tarefa: tarefas[index]);
              },
            ),
    );
  }
}
