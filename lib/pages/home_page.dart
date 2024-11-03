import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/favoritas_page.dart';
import '../pages/tarefas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  List<Widget> _buildDaysOfMonth() {
    final DateTime now = DateTime.now();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    List<Widget> days = [];
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(now.year, now.month, i);
      String dayAbbreviation = DateFormat('E').format(date);
      days.add(
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: i == now.day ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                i.toString(),
                style: TextStyle(
                  color: i == now.day ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              dayAbbreviation,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedMonth = DateFormat('MMMM').format(now);
    final String formattedDay = DateFormat('EEEE').format(now);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today, $formattedDay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  formattedMonth,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildDaysOfMonth(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: pc,
              onPageChanged: setPaginaAtual,
              children: [
                TarefasPage(),
                FavoritasPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        onTap: (pagina) {
          pc.animateToPage(
            pagina,
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todas'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritas'),
        ],
      ),
    );
  }
}
