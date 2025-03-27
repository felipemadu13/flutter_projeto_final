import 'package:flutter/material.dart';
import 'package:flutter_projeto_final/data/api_service.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'package:flutter_projeto_final/data/user_model.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

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
    try {
      ApiService apiService = ApiService();  // Instanciando o ApiService
      List<dynamic> fetchedNoticias = await apiService.fetchNoticias();
      setState(() {
        noticias = fetchedNoticias;
      });
    } catch (e) {
      print('Erro ao carregar as notícias: $e');
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
      appBar: AppBar(
        title: Text("Bem-vindo, ${widget.user.nome}"),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.user.avatarUrl),
          ),
          SizedBox(width: 10),
        ],
      ),
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
                        color: Color.fromARGB(255, 41, 109, 94),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      noticias[index]['texto'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Categoria: ${noticias[index]['categoria']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
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
