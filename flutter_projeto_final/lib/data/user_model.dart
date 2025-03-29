class User {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final String avatarUrl;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

}
