import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/noticia_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// getAllNoticias
  Future<List<Noticia>> fetchNoticias() async {
    final snapshot = await _db.collection('noticias').get();
    return snapshot.docs.map((doc) => Noticia.fromMap(doc.data())).toList();
  }

  Future<String?> fetchUltimaImagem(List<int> idImagens) async {
    if (idImagens.isEmpty) return null;

    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('imagens')
        .where('idImagem', whereIn: idImagens)
        .orderBy('dataInclusao', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['arquivoImagem']; // Retorna a URL da imagem
    }
    return null;
  }
}
