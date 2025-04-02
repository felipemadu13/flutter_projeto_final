import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
      ),
      body: currentUser == null
          ? const Center(child: Text('Nenhum usuário logado.'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações do Usuário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 41, 109, 94),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Nome: ${currentUser.displayName ?? 'Não disponível'}'),
                      Text('Email: ${currentUser.email ?? 'Não disponível'}'),
                      Text('UID: ${currentUser.uid}'),
                      Text('Email Verificado: ${currentUser.emailVerified ? 'Sim' : 'Não'}'),
                      Text('Número de Telefone: ${currentUser.phoneNumber ?? 'Não disponível'}'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}