import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('banana'),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
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
          ],
          selectedItemColor: Colors.amber[800],
          onTap: (int index) {
            print('Item $index');
          },
      ),
    );
  }
}
