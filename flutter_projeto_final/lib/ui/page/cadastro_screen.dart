import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/services/auth_service.dart';
import 'package:flutter_projeto_final/ui/page/login_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cadastrarUsuario() async {
    try {

      final userCredential = await authService.value.createAccount(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );


      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        debugPrint("E-mail de verificação enviado para o usuário.");
      }

      String uid = userCredential.user!.uid;

      await _firestore.collection('autores').doc(uid).set({
        'nome': nomeController.text.trim(),
        'sobrenome': sobrenomeController.text.trim(),
        'email': emailController.text.trim(),
        'avatarUrl': '',
        'uid': uid,
      });

      await authService.value.updateUsername(
        '${nomeController.text.trim()} ${sobrenomeController.text.trim()}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro realizado com sucesso! Verifique seu e-mail para ativar sua conta.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint("Erro ao cadastrar usuário: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar usuário: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: sobrenomeController,
              decoration: const InputDecoration(labelText: "Sobrenome"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: cadastrarUsuario,
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}