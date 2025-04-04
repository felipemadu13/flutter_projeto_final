import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/ui/page/news_form_screen.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:flutter_projeto_final/data/noticia_model.dart';


class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> scheduledNoticias = [];

  @override
  void initState() {
    super.initState();
    fetchScheduledNoticias();
  }

  Future<void> fetchScheduledNoticias() async {
    final noticias = await _firestoreService.fetchNoticias();
    final now = DateTime.now();

    final filteredNoticias = noticias.where((noticia) {
      final inicioValidade = noticia.dataInicioValidade;
      return inicioValidade.isAfter(now);
    }).toList();

    filteredNoticias.sort((a, b) => a.dataInicioValidade.compareTo(b.dataInicioValidade));

    final Map<String, List<Noticia>> groupedByWeek = {};
    for (var noticia in filteredNoticias) {
      final startOfWeek = noticia.dataInicioValidade.subtract(Duration(days: noticia.dataInicioValidade.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final weekKey = '${DateFormat('dd/MM/yyyy').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}';

      groupedByWeek.putIfAbsent(weekKey, () => []);
      groupedByWeek[weekKey]!.add(noticia);
    }

    setState(() {
      scheduledNoticias = groupedByWeek.entries.map((entry) {
        return {'week': entry.key, 'noticias': entry.value};
      }).toList();
    });
  }

  void _navigateToEditScreen(BuildContext context, Noticia noticia) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsFormScreen(noticia: {
          'idNoticia': noticia.idnoticia,
          'autorId': noticia.autorId,
          'titulo': noticia.titulo,
          'texto': noticia.texto,
          'imagens': noticia.imagens,
          'categorias': noticia.categorias,
          'dataInclusao': noticia.dataInclusao,
          'dataInicioValidade': noticia.dataInicioValidade,
          'dataFimValidade': noticia.dataFimValidade,
        }),

      ),
    );

    if (result == true) {
      fetchScheduledNoticias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: fetchScheduledNoticias,
        child: scheduledNoticias.isEmpty
            ? const Center(
          child: Text(
            'Nenhuma notícia agendada.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: scheduledNoticias.length,
          itemBuilder: (context, index) {
            final weekGroup = scheduledNoticias[index];
            final week = weekGroup['week'];
            final noticias = weekGroup['noticias'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Semana: $week',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 41, 109, 94),
                    ),
                  ),
                ),
                ...noticias.map<Widget>((noticia) {
                  final formatador = DateFormat("dd/MM/yyyy 'às' HH:mm");
                  final dataInicioFormatada = formatador.format(noticia.dataInicioValidade);
                  final dataFimFormatada = noticia.dataFimValidade != null
                      ? formatador.format(noticia.dataFimValidade!)
                      : 'Sem data de fim';

                  return GestureDetector(
                    onTap: () => _navigateToEditScreen(context, noticia),
                    child: Card(
                      margin: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noticia.titulo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 41, 109, 94),
                              ),
                            ),
                            Text(
                              'Data de início: $dataInicioFormatada',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            Text(
                              'Data de fim: $dataFimFormatada',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2, 
        onTap: (index) {
          _navigateToScreen(context, index);
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/news_form');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }
}
