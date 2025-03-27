import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 2) {
          Navigator.pushNamed(context, '/schedule');
        } else {
          onTap(index);
        }
      },
      selectedItemColor: Color.fromARGB(255, 53, 138, 118),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.newspaper),
          label: 'Notícias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.post_add),
          label: 'Criar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_agenda),
          label: 'Agendamentos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
