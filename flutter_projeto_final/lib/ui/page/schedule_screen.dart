import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/ui/page/news_form_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import necessário para formatar as datas

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<dynamic> scheduledNoticias = [];

  @override
  void initState() {
    super.initState();
    fetchScheduledNoticias();
  }

  Future<void> fetchScheduledNoticias() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/noticias'));
    if (response.statusCode == 200) {
      setState(() {
        final now = DateTime.now();
        final noticias = json.decode(utf8.decode(response.bodyBytes));

        // Filtra as notícias com dataInicioValidade superior à data atual
        final filteredNoticias = noticias.where((noticia) {
          final dataInicioValidade = noticia['dataInicioValidade'];
          if (dataInicioValidade != null && dataInicioValidade.isNotEmpty) {
            final inicioValidade = DateTime.parse(dataInicioValidade);
            return inicioValidade.isAfter(now);
          }
          return false;
        }).toList();

        // Ordena as notícias por dataInicioValidade em ordem crescente
        filteredNoticias.sort((a, b) {
          final dateA = DateTime.parse(a['dataInicioValidade']);
          final dateB = DateTime.parse(b['dataInicioValidade']);
          return dateA.compareTo(dateB); // Ordena em ordem crescente
        });

        // Agrupa as notícias por semana
        final Map<String, List<dynamic>> groupedByWeek = {};
        for (var noticia in filteredNoticias) {
          final dataInicioValidade = DateTime.parse(noticia['dataInicioValidade']);
          final startOfWeek = dataInicioValidade.subtract(Duration(days: dataInicioValidade.weekday - 1)); // Segunda-feira
          final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Domingo
          final weekKey = '${DateFormat('dd/MM/yyyy').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}';

          if (!groupedByWeek.containsKey(weekKey)) {
            groupedByWeek[weekKey] = [];
          }
          groupedByWeek[weekKey]!.add(noticia);
        }

        // Atualiza o estado com as notícias agrupadas
        scheduledNoticias = groupedByWeek.entries.map((entry) {
          return {
            'week': entry.key,
            'noticias': entry.value,
          };
        }).toList();
      });
    } else {
      throw Exception('Falha ao carregar as notícias agendadas.');
    }
  }

  void _navigateToEditScreen(BuildContext context, Map<String, dynamic> noticia) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsFormScreen(
          noticia: noticia, // Passa a notícia para a tela de edição
        ),
      ),
    );

    if (result == true) {
      fetchScheduledNoticias(); // Atualiza a lista de notícias ao retornar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
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
                        final dataInicioValidade = DateTime.parse(noticia['dataInicioValidade']);
                        final dataFimValidade = noticia['dataFimValidade'] != null &&
                                noticia['dataFimValidade'].isNotEmpty
                            ? DateTime.parse(noticia['dataFimValidade'])
                            : null;

                        // Formata as datas
                        final formatador = DateFormat('dd/MM/yyyy \'às\' HH:mm');
                        final dataInicioFormatada = formatador.format(dataInicioValidade);
                        final dataFimFormatada = dataFimValidade != null ? formatador.format(dataFimValidade) : 'Sem data de fim';

                        return GestureDetector(
                          onTap: () => _navigateToEditScreen(context, noticia), // Navega para a tela de edição
                          child: Card(
                            margin: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        noticia['titulo'],
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
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
      ),
    );
  }
}