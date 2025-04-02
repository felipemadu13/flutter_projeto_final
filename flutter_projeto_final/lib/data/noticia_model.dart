import 'package:cloud_firestore/cloud_firestore.dart';

class Noticia {
  final int idnoticia;
  final String autorId;
  final String titulo;
  final String texto;
  final List<int> imagens;
  final List<int> categorias;
  final DateTime dataInclusao;
  final DateTime dataInicioValidade;
  final DateTime? dataFimValidade;

  Noticia({
    required this.idnoticia,
    required this.autorId,
    required this.titulo,
    required this.texto,
    required this.imagens,
    required this.categorias,
    required this.dataInclusao,
    required this.dataInicioValidade,
    this.dataFimValidade,
  });

  // Método para converter um Map em uma instância de Noticia
  factory Noticia.fromMap(Map<String, dynamic> data) {
    return Noticia(
      idnoticia: data['idNoticia'] ?? 0,
      autorId: data['autorId'] ?? '', 
      titulo: data['titulo'] ?? '',
      texto: data['texto'] ?? '',
      imagens: List<int>.from(data['imagens'] ?? []),
      categorias: List<int>.from(data['categorias'] ?? []),
      dataInclusao: (data['dataInclusao'] as Timestamp).toDate(),
      dataInicioValidade: (data['dataInicioValidade'] as Timestamp).toDate(),
      dataFimValidade: data['dataFimValidade'] != null ? (data['dataFimValidade'] as Timestamp).toDate() : null,
    );
  }


  // Método para converter uma instância de Noticia em um Map
  Map<String, dynamic> toMap() {
    return {
      'idNoticia': idnoticia,
      'autorId': autorId,
      'titulo': titulo,
      'texto': texto,
      'imagens': imagens,
      'categorias': categorias,
      'dataInclusao': Timestamp.fromDate(dataInclusao),
      'dataInicioValidade': Timestamp.fromDate(dataInicioValidade),
      'dataFimValidade': dataFimValidade != null ? Timestamp.fromDate(dataFimValidade!) : null,
    };
  }
}
