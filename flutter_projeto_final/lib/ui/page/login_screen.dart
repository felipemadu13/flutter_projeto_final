import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projeto_final/ui/page/home_screen.dart';
import 'package:flutter_projeto_final/data/autor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String? errorMessage;

  // Função de login sem Firebase Authentication, usando apenas Firestore
  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String email = emailController.text;
      String senha = senhaController.text;

      // Buscar autor no Firestore com base no e-mail
      QuerySnapshot querySnapshot = await _firestore
          .collection('autores')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = "E-mail ou senha incorretos!";
          isLoading = false;
        });
        return;
      }

      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      Autor autor = Autor.fromFirestore(docSnapshot);

      // Verifica se a senha corresponde à armazenada no Firestore
      if (senha != docSnapshot['senha']) {
        setState(() {
          errorMessage = "E-mail ou senha incorretos!";
          isLoading = false;
        });
        return;
      }

      // Se as senhas corresponderem, navega para a tela inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(autor: autor)),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao realizar o login!";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logotipo_tce.png',
                height: 150,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Digite seu e-mail",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    labelText: "Digite sua senha",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                width: 280,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF347D6B), // Cor do botão
                  ),
                  child: Text(
                    "ENTRAR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
