import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/user_model.dart';

class ApiService {
  static const String baseUrlAutores = "http://10.0.2.2:3000/autores";
  static const String baseUrlNoticias = "http://10.0.2.2:3000/noticias";

  // Função de login
  Future<User?> login(String email, String senha) async {
    final response = await http.get(Uri.parse(baseUrlAutores));

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);

      for (var user in users) {
        if (user['email'] == email && user['senha'] == senha) {
          return User.fromJson(user);
        }
      }
    }
    return null;
  }

  // Função para buscar as notícias
  Future<List<dynamic>> fetchNoticias() async {
    final response = await http.get(Uri.parse(baseUrlNoticias));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Falha ao carregar as notícias');
    }
  }
}
