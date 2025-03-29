import 'package:cloud_firestore/cloud_firestore.dart';

class Autor {
  final String idAutor;
  final String nome;
  final String cpf;
  final String email;
  final String avatarUrl;

  Autor({
    required this.idAutor,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.avatarUrl,
  });

  // Factory method para criar um Autor a partir de um documento do Firestore
  factory Autor.fromFirestore(DocumentSnapshot docSnapshot) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    return Autor(
      idAutor: docSnapshot.id,
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}
