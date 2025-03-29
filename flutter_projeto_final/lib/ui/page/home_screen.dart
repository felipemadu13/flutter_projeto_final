import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'package:flutter_projeto_final/ui/page/news_form_screen.dart'; // Import da tela de criação
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> noticias = [];
  List<dynamic> filteredNoticias = [];
  int _selectedIndex = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/noticias'));
  if (response.statusCode == 200) {
    setState(() {
      noticias = json.decode(utf8.decode(response.bodyBytes));

      final now = DateTime.now();

      noticias = noticias
          .where((noticia) {
            final dataInicioValidade = noticia['dataInicioValidade'];
            final dataFimValidade = noticia['dataFimValidade'];


            // Verifica se dataInicioValidade não é nula ou vazia
            if (dataInicioValidade == null || dataInicioValidade.isEmpty) {
              return false;
            }

            final inicioValidade = DateTime.parse(dataInicioValidade);

            // Exclui notícias com dataInicioValidade superior à data atual
            if (inicioValidade.isAfter(now)) {
              return false;
            }

            // Verifica se dataFimValidade é válida e se a notícia ainda é válida
            if (dataFimValidade != null && dataFimValidade.isNotEmpty) {
              final fimValidade = DateTime.parse(dataFimValidade);
              if (fimValidade.isBefore(now)) {
                return false;
              }
            }

            return true;
          })
          .toList();

      noticias.sort((a, b) {
        final dateA = DateTime.parse(a['dataInicioValidade']);
        final dateB = DateTime.parse(b['dataInicioValidade']);
        return dateB.compareTo(dateA); 
      });

      filteredNoticias = noticias; 
    });
  } else {
    throw Exception('Falha ao carregar as notícias.');
  }
}

  Future<void> _showDeleteConfirmationDialog(BuildContext context, int index) async {
  final noticia = filteredNoticias[index];
  final noticiaId = noticia['id']; // Supondo que cada notícia tenha um ID único

  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir esta notícia?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancela a exclusão
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirma a exclusão
            },
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await _deleteNoticia(noticiaId);
  }
}

Future<void> _deleteNoticia(String noticiaId) async {
  final response = await http.delete(Uri.parse('http://10.0.2.2:3000/noticias/$noticiaId'));

  if (response.statusCode == 200) {
    setState(() {
      noticias.removeWhere((noticia) => noticia['id'] == noticiaId);
      filteredNoticias.removeWhere((noticia) => noticia['id'] == noticiaId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notícia excluída com sucesso!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Falha ao excluir a notícia.')),
    );
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
    fetchNoticias(); // Atualiza a lista de notícias ao retornar
  }
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Navega para a tela de criação de notícias
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewsFormScreen()),
      ).then((result) {
        if (result == true) {
          // Atualiza as notícias ao retornar da tela de criação
          fetchNoticias();
          setState(() {
            _selectedIndex = 0; // Volta para a aba "Notícias"
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            setState(() {
              searchQuery = query.toLowerCase();
              filteredNoticias = noticias
                  .where((noticia) =>
                      noticia['titulo'].toLowerCase().contains(searchQuery))
                  .toList();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Pesquisar notícias...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
      ),
      body: RefreshIndicator(
        onRefresh: fetchNoticias, 
        child: filteredNoticias.isEmpty
            ? const Center(
                child: CircularProgressIndicator(), 
              )
            : ListView.builder(
                itemCount: filteredNoticias.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          filteredNoticias[index]['imagemUrl'] ?? '',
                          errorBuilder: (context, error, stackTrace) {
                            // Exibe uma imagem padrão se o caminho for inválido ou vazio
                            return Image.asset(
                              'assets/images/default_image.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  filteredNoticias[index]['titulo'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 41, 109, 94),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToEditScreen(context, filteredNoticias[index]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(context, index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
