import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/data/noticia_model.dart';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:flutter_projeto_final/ui/page/news_form_screen.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Noticia> noticias = [];
  List<Noticia> filteredNoticias = [];
  int _selectedIndex = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    final result = await _firestoreService.fetchNoticias();
    setState(() {
      noticias = result;
      filteredNoticias = noticias;
    });
  }

  Future<String> getImagemUrl(Noticia noticia) async {
    final imagemUrl = await _firestoreService.fetchUltimaImagem(noticia.imagens);
    return imagemUrl ?? 'assets/images/default_image.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            setState(() {
              searchQuery = query.toLowerCase();
              filteredNoticias = noticias.where((n) => n.titulo.toLowerCase().contains(searchQuery)).toList();
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
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: filteredNoticias.length,
          itemBuilder: (context, index) {
            final noticia = filteredNoticias[index];

            return FutureBuilder<String>(
              future: getImagemUrl(noticia),
              builder: (context, snapshot) {
                final imagemUrl = snapshot.data ?? 'assets/images/default_image.jpg';

                return Card(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(noticiaId: noticia.idnoticia),
                            ),
                          );
                        },
                        child: Image.network(
                          imagemUrl,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/default_image.jpg', fit: BoxFit.cover);
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                noticia.titulo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 41, 109, 94),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Passar os dados da notícia para a tela de formulário
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsFormScreen(noticia: {
                                          'id': noticia.idnoticia,
                                          'titulo': noticia.titulo,
                                          'texto': noticia.texto,
                                          'imagemUrl': imagemUrl,  // Imagem atual
                                          'dataInicioValidade': noticia.dataInicioValidade,
                                          'dataFimValidade': noticia.dataFimValidade,
                                        }),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Ação de deletar
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: _selectedIndex, onTap: (index) {}),
    );
  }
}
