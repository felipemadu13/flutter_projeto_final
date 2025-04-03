import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projeto_final/ui/page/home_screen.dart';
import 'package:flutter_projeto_final/ui/page/login_screen.dart'; // Import da tela de login
import 'package:flutter_projeto_final/services/auth_service.dart'; // Import do auth_service
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _selectedImage;

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

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        avatarUrlController.text = pickedFile.path; // Atualiza o campo com o caminho da imagem
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma imagem selecionada.')),
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

  Future<void> signOut() async {
    try {
      await authService.value.signOut(); // Chama o método signOut do auth_service
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Redireciona para a tela de login
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
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
                    Center(
                      child: CircleAvatar(
                        radius: 50, // Tamanho do círculo
                        backgroundImage: avatarUrlController.text.isNotEmpty
                            ? FileImage(File(avatarUrlController.text)) // Exibe a imagem do avatar
                            : const AssetImage('assets/images/default_image.png') as ImageProvider, // Imagem padrão
                        backgroundColor: Colors.grey[200], // Cor de fundo caso não haja imagem
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
                        enabled: false, // Adicionado para desabilitar visualmente o campo
                      ),
                      readOnly: true, // Impede a edição do campo
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: avatarUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
                      ),
                      child: const Text(
                        'Selecionar Imagem',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
                      ),
                      child: const Text(
                        'Salvar Alterações',
                        style: TextStyle(color: Colors.white), // Define a cor do texto como branco
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: signOut, // Botão para sair
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.white),
                      ),
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