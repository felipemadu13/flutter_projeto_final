import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/data/autor_model.dart';
import 'package:flutter_projeto_final/ui/page/home_screen.dart';



class CadastroScreen extends StatelessWidget {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAutor(Autor autor) async {
    try {
      int idAutor = DateTime.now().millisecondsSinceEpoch;
      Autor novoAutor = Autor(
        idAutor: idAutor,
        Nome: autor.Nome,
        cpf: autor.cpf,
        email: autor.email,
        avatarUrl: autor.avatarUrl,
      );

      await _firestore.collection('autores').add({
        'idAutor': novoAutor.idAutor,
        'Nome': novoAutor.Nome,
        'cpf': novoAutor.cpf,
        'email': novoAutor.email,
        'avatarUrl': novoAutor.avatarUrl,
        'senha': senhaController.text,
      });
    } catch (e) {
      print("Erro ao adicionar autor: $e");
      throw Exception("Erro ao adicionar autor");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: nomeController, decoration: InputDecoration(labelText: "Nome")),
            TextField(controller: cpfController, decoration: InputDecoration(labelText: "CPF")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "E-mail")),
            TextField(controller: senhaController, decoration: InputDecoration(labelText: "Senha"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Autor novoAutor = Autor(
                  idAutor: DateTime.now().millisecondsSinceEpoch,
                  Nome: nomeController.text,
                  cpf: cpfController.text,
                  email: emailController.text,
                  avatarUrl: "",
                );
                await addAutor(novoAutor);

                // Navega para HomeScreen após o cadastro
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text("Cadastrar"),
            ),

          ],
        ),
      ),
    );
  }
}