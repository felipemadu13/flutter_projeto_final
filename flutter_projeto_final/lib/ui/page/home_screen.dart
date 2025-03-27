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
  List<dynamic> filteredNoticias = [];
  int _selectedIndex = 0;
  String searchQuery = '';

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
        filteredNoticias = noticias; // Inicialmente, todas as notícias são exibidas
      });
    } else {
      throw Exception('Falha ao carregar as notícias');
    }
  }

  void _onSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredNoticias = noticias
          .where((noticia) =>
              noticia['titulo'].toLowerCase().contains(searchQuery))
          .toList();
    });
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
      appBar: AppBar(
        title: TextField(
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Pesquisar notícias...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 41, 109, 94),
      ),
      body: Center(
        child: filteredNoticias.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: filteredNoticias.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(filteredNoticias[index]['imagemUrl']),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            filteredNoticias[index]['titulo'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 41, 109, 94),
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
