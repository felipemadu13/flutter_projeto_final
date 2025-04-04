import 'package:flutter/material.dart';
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

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(noticia.titulo, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text("Por $autorNome", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    Text(noticia.texto, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0, // Define o índice atual (ajuste conforme necessário)
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
