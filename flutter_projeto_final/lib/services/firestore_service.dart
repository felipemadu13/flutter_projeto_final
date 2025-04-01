import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/data/autor_model.dart';
import '../data/noticia_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// getAllNoticias
  Future<List<Noticia>> fetchNoticias() async {
    final snapshot = await _db.collection('noticias').get();
    return snapshot.docs.map((doc) => Noticia.fromMap(doc.data())).toList();
  }

  /// Método para buscar a última imagem adicioanda a notícia
  Future<String?> fetchUltimaImagem(List<int> idImagens) async {
    if (idImagens.isEmpty) return null;

    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('imagens')
        .where('idImagem', whereIn: idImagens)
        .orderBy('dataInclusao', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['arquivoImagem'];
    }
    return null;
  }

  /// getByIdnoticia
  Future<Noticia?> getNoticiaById(int id) async {
    var querySnapshot = await _db
        .collection('noticias')
        .where('idNoticia', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return Noticia.fromMap(doc.data());
    }

    return null;
  }


  /// getByIdAutor
  Future<Autor?> getAutorById(int idAutor) async {
    var snapshot = await _db.collection('autores')
        .where('idAutor', isEqualTo: idAutor)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data();
      print("Dados do Autor: $data"); // Depuração

      return Autor.fromFirestore(snapshot.docs.first);
    }

    print("Nenhum autor encontrado para idAutor: $idAutor");
    return null;
  }



}
