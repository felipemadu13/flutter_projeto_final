import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  final int idCategoria;
  final String Nome;
  final DateTime dataInclusao;

  Categoria({
    required this.idCategoria,
    required this.Nome,
    required this.dataInclusao,
  });


  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      idCategoria: map['idCategoria'] as int,
      Nome: map['Nome'] as String,
      dataInclusao: (map['dataInclusao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'nome': Nome,
      'dataInclusao': dataInclusao,
    };
  }
}