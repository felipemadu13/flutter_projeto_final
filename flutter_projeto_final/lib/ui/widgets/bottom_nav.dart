import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:flutter_projeto_final/ui/page/news_form_screen.dart';
import 'package:flutter_projeto_final/ui/page/profile_screen.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.email != null) {
      final autor = await _firestoreService.getAutorByEmail(currentUser.email!);
      if (autor != null && autor.avatarUrl != null) {
        setState(() {
          _avatarUrl = autor.avatarUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewsFormScreen()),
          );
        } else if (index == 2) {
          Navigator.pushNamed(context, '/schedule');
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else {
          widget.onTap(index);
        }
      },
      selectedItemColor: const Color.fromARGB(255, 53, 138, 118),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.newspaper),
          label: 'Notícias',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.post_add),
          label: 'Criar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.view_agenda),
          label: 'Agendamentos',
        ),
        BottomNavigationBarItem(
          icon: _avatarUrl != null
              ? CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(_avatarUrl!),
          )
              : const Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}