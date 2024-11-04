import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../widgets/tarefa_card.dart';

class CalendarioCard extends StatefulWidget {
  final DateTime selectedDate;

  const CalendarioCard({super.key, required this.selectedDate});

  @override
  State<CalendarioCard> createState() => _CalendarioCardState();
}

class _CalendarioCardState extends State<CalendarioCard> {
  late TarefasRepository tarefasRepo;

  List<Tarefa> _getTarefasForSelectedDate() {
    // Filtra as tarefas pela data selecionada
    return TarefasRepository.tabela.where((tarefa) {
      return tarefa.data.year == widget.selectedDate.year &&
          tarefa.data.month == widget.selectedDate.month &&
          tarefa.data.day == widget.selectedDate.day;
    }).toList();
    //return tarefasRepo.getData((tarefa, selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as tarefas para a data selecionada
    //tarefasRepo = Provider.of<TarefasRepository>(context);
    final tarefas = _getTarefasForSelectedDate();
    final formattedDate =
        DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR').format(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
