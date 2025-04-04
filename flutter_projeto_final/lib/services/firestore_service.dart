import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/data/autor_model.dart';
import 'package:flutter_projeto_final/data/categoria_model.dart';
import 'package:flutter_projeto_final/data/imagem_model.dart';
import '../data/noticia_model.dart';
import 'package:http/http.dart' as http;

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

  /// Método para gerar um idNoticia automaticamente
  static int _idNoticiaCounter = 0;
  Future<int> _generateIdNoticia() async {
    var snapshot = await _db.collection('noticias').orderBy('idNoticia', descending: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['idNoticia'] + 1;
    }
    return _idNoticiaCounter++;
  }

  /// Post notícia
  Future<void> createNoticia(Noticia noticia, File? imageFile, List<int> categoriasSelecionadas) async {
    int idNoticia = await _generateIdNoticia();
    List<int> imagensIds = [];

    if (imageFile != null) {
      String? imageUrl = await uploadImageToImgBB(imageFile);
      if (imageUrl != null) {
        int idImagem = DateTime.now().millisecondsSinceEpoch;

        ImagemModel imagem = ImagemModel(
          idImagem: idImagem,
          arquivoImagem: imageUrl,
          dataInclusao: DateTime.now(),
        );

        await _db.collection('imagens').add(imagem.toMap());
        imagensIds.add(idImagem);
      }
    }

    Noticia novaNoticia = Noticia(
      idnoticia: idNoticia,
      autorId: noticia.autorId,
      titulo: noticia.titulo,
      texto: noticia.texto,
      imagens: imagensIds,
      categorias: categoriasSelecionadas,
      dataInclusao: DateTime.now(),
      dataInicioValidade: noticia.dataInicioValidade,
      dataFimValidade: noticia.dataFimValidade,
    );

    await _db.collection('noticias').add(novaNoticia.toMap());
  }

  /// Put Noticia
  Future<void> editNoticia(int idNoticia, Map<String, dynamic> novosDados) async {
    try {
      var querySnapshot = await _db
          .collection('noticias')
          .where('idNoticia', isEqualTo: idNoticia)
          .limit(1)
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;
        await _db.collection('noticias').doc(docId).update(novosDados);
      } else {
        throw Exception("Notícia não encontrada");
      }
    } catch (e) {
      print("Erro ao editar notícia: $e");
    }
  }

  /// Deletar notícia
  Future<void> deleteNoticia(int idNoticia) async {
    try {
      var querySnapshot = await _db
          .collection('noticias')
          .where('idNoticia', isEqualTo: idNoticia)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;
        await _db.collection('noticias').doc(docId).delete();
      } else {
        throw Exception("Notícia não encontrada");
      }
    } catch (e) {
      print("Erro ao deletar notícia: $e");
    }
  }


  /// getByAutorId
  Future<Autor?> getAutorById(String uid) async {
    try {
      var snapshot = await _db.collection('autores')
          .doc(uid) // Busca diretamente pelo UID do documento
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        print("Dados do Autor: $data"); // Depuração
        return Autor.fromFirestore(snapshot);
      }

      print("Nenhum autor encontrado para uid: $uid");
      return null;
    } catch (e) {
      print("Erro ao buscar autor por uid: $e");
      return null;
    }
  }


  /// Método para fazer upload de imagem para o ImgBB
  Future<String?> uploadImageToImgBB(File imageFile) async {
    const String apiKey = '58f3338a6851c75d3c2724fe800cdadc';
    final Uri uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final bytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(bytes);

    final response = await http.post(
      uri,
      body: {'image': base64Image},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['url'];
    }
    return null;
  }

  /// Método para buscar todas as categorias cadastradas
  Future<List<Categoria>> fetchCategorias() async {
    final snapshot = await _db.collection('categorias').get();
    return snapshot.docs.map((doc) => Categoria.fromMap(doc.data())).toList();
  }

  /// Método para criar uma nova categoria
  Future<int> createCategoria(String nomeCategoria) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('categorias')
        .add({'nome': nomeCategoria});

    return docRef.id.hashCode;
  }

  Future<int> getCategoriaIdByNome(String nomeCategoria) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('categorias')
        .where('Nome', isEqualTo: nomeCategoria)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.get('idCategoria') as int;
    } else {
      throw Exception('Categoria não encontrada');
    }
  }






}
