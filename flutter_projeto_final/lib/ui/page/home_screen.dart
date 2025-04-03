import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/data/noticia_model.dart';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:flutter_projeto_final/ui/page/news_form_screen.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'news_detail_screen.dart';
import 'package:flutter_projeto_final/data/autor_model.dart';

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

  Future<void> deleteNoticia(int noticiaId) async {
    await _firestoreService.deleteNoticia(noticiaId);
    fetchNoticias(); // Atualiza a lista após a exclusão
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

                return FutureBuilder<Autor?>(
                  future: _firestoreService.getAutorById(noticia.autorId), 
                  builder: (context, autorSnapshot) {
                    if (autorSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final autor = autorSnapshot.data;
                    final autorNome = autor?.nome ?? "Autor desconhecido";
                    final autorAvatar = autor?.avatarUrl ?? 'assets/images/default_image.png';

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
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsFormScreen(
                                    noticia: {
                                      'idnoticia': noticia.idnoticia,
                                      'titulo': noticia.titulo,
                                      'texto': noticia.texto,
                                      'imagemUrl': imagemUrl,
                                      'dataInicioValidade': noticia.dataInicioValidade,
                                      'dataFimValidade': noticia.dataFimValidade,
                                      'categorias': noticia.categorias,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: AspectRatio(
                              aspectRatio: 16 / 9, // Substitua pela proporção da sua imagem default_image.jpg
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5), // Define o border radius de 8px
                                child: Image.network(
                                  imagemUrl,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_image.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  fit: BoxFit.cover, // Garante que a imagem preencha o espaço
                                ),
                              ),
                            ),
                          ),
                          Padding(
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12, 
                                      backgroundImage: autorAvatar.isNotEmpty
                                          ? FileImage(File(autorAvatar))
                                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      autorNome,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
