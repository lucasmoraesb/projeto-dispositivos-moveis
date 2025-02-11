import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // Importando o pacote de permissões

import '../models/tarefa.dart';
import '../repositories/tarefas_repository.dart';
import '../repositories/casas_repository.dart';
import '../services/notification_service.dart'; // Importação do serviço de notificações

class NovaTarefaPage extends StatefulWidget {
  const NovaTarefaPage({super.key});

  @override
  State<NovaTarefaPage> createState() => _NovaTarefaPageState();
}

class _NovaTarefaPageState extends State<NovaTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  String? _responsavel;
  DateTime? _dataSelecionada;

  @override
  Widget build(BuildContext context) {
    final casasRepo = Provider.of<CasasRepository>(context);
    final senhaCasa = casasRepo.senhaCasaAtual;
    final membros = casasRepo.obterMembrosDaCasa();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da tarefa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              DropdownButtonFormField<String>(
                value: _responsavel,
                decoration: const InputDecoration(labelText: 'Responsável'),
                items: membros
                    .map((membro) => DropdownMenuItem<String>(
                          value: membro,
                          child: Text(membro),
                        ))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    _responsavel = valor;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o responsável';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final dataSelecionada = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (dataSelecionada != null) {
                    // Após a seleção da data, mostre o seletor de hora
                    final horaSelecionada = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          DateTime.now()), // Hora atual como padrão
                    );
                    if (horaSelecionada != null) {
                      setState(() {
                        // Combine a data e a hora escolhidas
                        _dataSelecionada = DateTime(
                          dataSelecionada.year,
                          dataSelecionada.month,
                          dataSelecionada.day,
                          horaSelecionada.hour,
                          horaSelecionada.minute,
                        );
                      });

                      // Verifique se a data selecionada está no futuro em relação ao horário atual
                      final now = DateTime.now();
                      if (_dataSelecionada!.isBefore(now)) {
                        // Caso a data esteja no passado, ajusta para o futuro (exemplo: 1 minuto a mais)
                        _dataSelecionada = now.add(const Duration(minutes: 1));
                      }

                      // Exibe a data e hora selecionadas
                      print(
                          'Data e Hora selecionadas: ${_dataSelecionada!.toLocal()}');
                    }
                  }
                },
                child: Text(
                  _dataSelecionada == null
                      ? 'Selecionar Data e Hora'
                      : 'Data e Hora: ${_dataSelecionada!.toLocal()}',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _dataSelecionada != null) {
                    // Verifique se a permissão foi concedida antes de exibir a notificação
                    var status = await Permission.notification.request();
                    if (status.isGranted) {
                      final novaTarefa = Tarefa(
                        nome: _nomeController.text,
                        data: _dataSelecionada!,
                        descricao: _descricaoController.text,
                        responsavel: _responsavel ?? '',
                        status: 'Não concluída',
                      );

                      final tarefasRepo = Provider.of<TarefasRepository>(
                          context,
                          listen: false);
                      await tarefasRepo.criarTarefa(senhaCasa, novaTarefa);

                      // **Exibindo a notificação no horário escolhido**
                      NotificationService.showNotificationAtScheduledTime(
                        0, // ID da notificação
                        _nomeController.text,
                        _descricaoController.text.isNotEmpty
                            ? _descricaoController.text
                            : "Lembrete de Tarefa",
                        _dataSelecionada!, // Hora e data selecionada pelo usuário
                      );

                      Navigator.pop(context, novaTarefa);
                    } else {
                      // Trate o caso onde a permissão foi negada
                      print('Permissão para notificações não foi concedida');
                    }
                  }
                },
                child: const Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
