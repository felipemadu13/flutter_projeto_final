import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import '../../services/firestore_service.dart';
import '../../data/noticia_model.dart';
import '../../data/autor_model.dart';
import '../widgets/bottom_nav.dart';

class NewsDetailScreen extends StatelessWidget {
  final int noticiaId;
  final FirestoreService firestoreService = FirestoreService();

  NewsDetailScreen({required this.noticiaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da Notícia"),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Noticia?>(
        future: firestoreService.getNoticiaById(noticiaId),
        builder: (context, noticiaSnapshot) {
          if (noticiaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (noticiaSnapshot.hasError || noticiaSnapshot.data == null) {
            return const Center(child: Text("Erro ao carregar notícia"));
          }

          var noticia = noticiaSnapshot.data!;

          return FutureBuilder<Autor?>(
            future: firestoreService.getAutorById(noticia.autorId),
            builder: (context, autorSnapshot) {
              if (autorSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              String autorNome = autorSnapshot.data?.nome ?? "Autor desconhecido";

              return SingleChildScrollView( 
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<String?>(
                    future: firestoreService.getCategoriaNomeById(noticia.categorias[0]),
                    builder: (context, categoriaSnapshot) {
                      if (categoriaSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (categoriaSnapshot.hasError || !categoriaSnapshot.hasData) {
                        return const Text(
                          "Categoria desconhecida",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                        );
                      }

                      String categoriaNome = categoriaSnapshot.data ?? "Categoria desconhecida";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(noticia.titulo, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            "Categoria: $categoriaNome",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text("Por $autorNome", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 16),
                          FutureBuilder<String?>(
                            future: firestoreService.getImagemUrlById(noticia.imagens[0]), 
                            builder: (context, imageSnapshot) {
                              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (imageSnapshot.hasError || !imageSnapshot.hasData) {
                                return Image.asset(
                                  'assets/images/default_image.jpg', 
                                  fit: BoxFit.cover,
                                );
                              }

                              String imageUrl = imageSnapshot.data!;

                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/default_image.jpg', 
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(noticia.texto, style: const TextStyle(fontSize: 16)),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0, 
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
    } else if (index == 2) {
      Navigator.pushNamed(context, '/schedule');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }
}
