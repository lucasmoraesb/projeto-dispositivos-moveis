import 'package:flutter/material.dart';
import '../pages/calendario_page.dart';
import '../pages/favoritas_page.dart';
import '../pages/tarefas_page.dart';
import '../pages/home_page.dart';

class PaginasController extends StatefulWidget {
  const PaginasController({super.key});

  @override
  State<PaginasController> createState() => _PaginasControllerState();
}

class _PaginasControllerState extends State<PaginasController> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  void setPaginaAtual(int pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: setPaginaAtual,
        children: const [
          HomePage(),
          CalendarioPage(), // Página de calendário
          TarefasPage(),
          FavoritasPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo, // Define o fundo como indigo
        currentIndex: paginaAtual,
        selectedItemColor: Colors.white, // Destaque para o item selecionado
        unselectedItemColor: const Color.fromARGB(
            132, 255, 255, 255), // Cor para os itens não selecionados
        type: BottomNavigationBarType.fixed, // Evita transparência
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendário'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todas'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritas'),
        ],
        onTap: (pagina) {
          pc.animateToPage(pagina,
              duration: const Duration(milliseconds: 400), curve: Curves.ease);
        },
      ),
    );
  }
}
