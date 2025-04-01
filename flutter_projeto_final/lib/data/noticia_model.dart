import 'package:cloud_firestore/cloud_firestore.dart';

class Noticia {
  final int idnoticia;
  final int idAutor;
  final String titulo;
  final String texto;
  final List<int> imagens;
  final List<int> categorias;
  final DateTime dataInclusao;
  final DateTime dataInicioValidade;
  final DateTime? dataFimValidade;

  Noticia({
    required this.idnoticia,
    required this.idAutor,
    required this.titulo,
    required this.texto,
    required this.imagens,
    required this.categorias,
    required this.dataInclusao,
    required this.dataInicioValidade,
    this.dataFimValidade,
  });

  factory Noticia.fromMap(Map<String, dynamic> data) {
    return Noticia(
      idnoticia: data['idNoticia'] ?? 0,
      idAutor: data['idAutor'] ?? 0,
      titulo: data['titulo'] ?? '',
      texto: data['texto'] ?? '',
      imagens: List<int>.from(data['imagens'] ?? []),
      categorias: List<int>.from(data['categorias'] ?? []),
      dataInclusao: (data['dataInclusao'] as Timestamp).toDate(),
      dataInicioValidade: (data['dataInicioValidade'] as Timestamp).toDate(),
      dataFimValidade: data['dataFimValidade'] != null ? (data['dataFimValidade'] as Timestamp).toDate() : null,
    );
  }
}