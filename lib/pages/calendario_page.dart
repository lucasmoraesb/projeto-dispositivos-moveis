import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/calendario_card.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now(); // Mantenha o estado do mês focado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Selecione uma Data"),
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
          ),
        ],
      ),
    );
  }
}
