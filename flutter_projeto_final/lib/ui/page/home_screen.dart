import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> noticias = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/noticias'));
    if (response.statusCode == 200) {
      setState(() {
        noticias = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Falha ao carregar as notícias');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Aqui você pode adicionar a navegação para outras telas
    print('Item $index selecionado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: noticias.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: noticias.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(noticias[index]['imagemUrl']),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            noticias[index]['titulo'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 41, 109, 94)
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
