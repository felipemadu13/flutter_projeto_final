import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projeto_final/ui/page/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController avatarUrlController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userDoc = await _firestore.collection('autores').doc(currentUser.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            nomeController.text = data?['nome'] ?? '';
            sobrenomeController.text = data?['sobrenome'] ?? '';
            emailController.text = data?['email'] ?? '';
            avatarUrlController.text = data?['avatarUrl'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dados do usuário não encontrados.')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum usuário logado.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os dados do usuário: $e')),
      );
    }
  }

  Future<void> updateUserData() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('autores').doc(currentUser.uid).update({
          'nome': nomeController.text.trim(),
          'sobrenome': sobrenomeController.text.trim(),
          'email': emailController.text.trim(),
          'avatarUrl': avatarUrlController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar os dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar Informações do Usuário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 41, 109, 94),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: sobrenomeController,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // O e-mail não pode ser editado
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: avatarUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
                      ),
                      child: const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    emailController.dispose();
    avatarUrlController.dispose();
    super.dispose();
  }
}