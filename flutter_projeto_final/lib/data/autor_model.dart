import 'package:cloud_firestore/cloud_firestore.dart';

class Autor {
  final String autorId;
  final String nome;
  final String cpf;
  final String email;
  final String avatarUrl;

  Autor({
    required this.autorId,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.avatarUrl,
  });


  factory Autor.fromFirestore(DocumentSnapshot docSnapshot) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    return Autor(
      autorId: data['autorId'] ?? 0, 
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}
