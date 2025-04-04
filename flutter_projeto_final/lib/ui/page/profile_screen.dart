import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'edit_profile_screen.dart'; 
import 'login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String nome = '';
  String sobrenome = '';
  String email = '';
  String avatarUrl = '';
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
            nome = data?['nome'] ?? '';
            sobrenome = data?['sobrenome'] ?? '';
            email = data?['email'] ?? '';
            avatarUrl = data?['avatarUrl'] ?? '';
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

  Future<void> _logout() async {
    try {
      await _auth.signOut(); // Faz o logout do Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Redireciona para a tela de login
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? (avatarUrl.startsWith('http') // Verifica se é uma URL de rede
                              ? NetworkImage(avatarUrl) as ImageProvider
                              : FileImage(File(avatarUrl)))
                          : const AssetImage('assets/images/default_image.png'),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$nome $sobrenome',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
                      ),
                      child: const Text(
                        'Editar Informações',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _logout, // Chama o método de logout
                      child: const Text(
                        'Sair',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
              
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3, // Índice da aba atual (3 para Perfil)
        onTap: (index) {
          _navigateToScreen(context, index);
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/news_form');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/schedule');
    }
  }
}