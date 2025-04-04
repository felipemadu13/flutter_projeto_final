import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/data/noticia_model.dart';
import 'package:flutter_projeto_final/data/categoria_model.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? noticia;

  const NewsFormScreen({super.key, this.noticia});

  @override
  _NewsFormScreenState createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  final TextEditingController _novaCategoriaController = TextEditingController();
  File? _selectedImage;
  final String _defaultImagePath = 'assets/images/default_image.jpg'; // Caminho da imagem padrão
  DateTime? _dataInicioValidade;
  DateTime? _dataFimValidade;
  final FirestoreService _firestoreService = FirestoreService();
  bool _criandoCategoria = false;
  List<String> _categorias = [];
  String? _categoriaSelecionada;
  bool _isEditing = false; // Indica se estamos editando uma notícia existente
  int? _noticiaId; // ID da notícia sendo editada
  String? _imageUrl; // URL da imagem armazenada no banco

  @override
  void initState() {
    super.initState();
    _carregarCategorias();

    // Verifica se estamos editando uma notícia existente
    if (widget.noticia != null) {
      _isEditing = true;
      _noticiaId = widget.noticia!['idnoticia'];
      _tituloController.text = widget.noticia!['titulo'];
      _textoController.text = widget.noticia!['texto'];

      if (widget.noticia!['dataInicioValidade'] is Timestamp) {
        _dataInicioValidade = (widget.noticia!['dataInicioValidade'] as Timestamp).toDate();
      } else if (widget.noticia!['dataInicioValidade'] is DateTime) {
        _dataInicioValidade = widget.noticia!['dataInicioValidade'];
      }

      if (widget.noticia!['dataFimValidade'] is Timestamp) {
        _dataFimValidade = (widget.noticia!['dataFimValidade'] as Timestamp).toDate();
      } else if (widget.noticia!['dataFimValidade'] is DateTime) {
        _dataFimValidade = widget.noticia!['dataFimValidade'];
      }

      // Valida a categoria selecionada
      final categoriasDaNoticia = widget.noticia!['categorias'] as List<dynamic>? ?? [];
      if (categoriasDaNoticia.isNotEmpty) {
        _categoriaSelecionada = categoriasDaNoticia[0].toString();
      }

      // Carrega a imagem associada à notícia, se existir
      if (widget.noticia!['imagemUrl'] != null && widget.noticia!['imagemUrl'].isNotEmpty) {
        setState(() {
          _selectedImage = null; // Não usamos um arquivo local aqui
          _imageUrl = widget.noticia!['imagemUrl']; // URL da imagem armazenada no banco
        });
      }
    }
  }

  Future<void> _carregarCategorias() async {
    List<Categoria> categorias = await _firestoreService.fetchCategorias();
    setState(() {
      _categorias = categorias.map((categoria) => categoria.Nome).toList();

      // Valida se a categoria selecionada ainda é válida
      if (_categoriaSelecionada != null && !_categorias.contains(_categoriaSelecionada)) {
        _categoriaSelecionada = null;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma imagem selecionada.')),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? (_dataInicioValidade ?? DateTime.now()) : (_dataFimValidade ?? DateTime.now());
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            _dataInicioValidade = selectedDateTime;
          } else {
            _dataFimValidade = selectedDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Obtém o usuário atual
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          throw Exception('Usuário não autenticado.');
        }

        // Obtém o UID do usuário atual
        final String uid = currentUser.uid;

        // Obtém as categorias selecionadas
        List<int> categoriasSelecionadas = _criandoCategoria
            ? [await _firestoreService.createCategoria(_novaCategoriaController.text)]
            : [await _firestoreService.getCategoriaIdByNome(_categoriaSelecionada!)];

        if (_isEditing) {
          // Atualiza a notícia existente
          await _firestoreService.editNoticia(_noticiaId!, {
            'titulo': _tituloController.text,
            'texto': _tituloController.text,
            'dataInicioValidade': _dataInicioValidade,
            'dataFimValidade': _dataFimValidade,
            'categorias': categoriasSelecionadas,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notícia atualizada com sucesso!')),
          );
        } else {
          // Cria uma nova notícia
          final noticia = Noticia(
            idnoticia: DateTime.now().millisecondsSinceEpoch,
            autorId: uid,
            titulo: _tituloController.text,
            texto: _textoController.text,
            imagens: [],
            categorias: categoriasSelecionadas,
            dataInclusao: DateTime.now(),
            dataInicioValidade: _dataInicioValidade ?? DateTime.now(),
            dataFimValidade: _dataFimValidade,
          );

          await _firestoreService.createNoticia(noticia, _selectedImage, categoriasSelecionadas);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notícia criada com sucesso!')),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar notícia: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          _isEditing ? 'Editar Notícia' : 'Cadastrar Notícia',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Exibe a imagem selecionada ou a imagem padrão com funcionalidade de clique
                GestureDetector(
                  onTap: _pickImage, // Chama o método para selecionar a imagem
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : (_imageUrl != null && _imageUrl!.isNotEmpty
                            ? Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                _defaultImagePath,
                                fit: BoxFit.cover,
                              )),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, insira o título' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _textoController,
                  decoration: const InputDecoration(labelText: 'Texto'),
                  maxLines: 5,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, insira o texto' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _categorias.contains(_categoriaSelecionada)
                      ? _categoriaSelecionada
                      : null,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem(
                        value: categoria, child: Text(categoria));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSelecionada = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, selecione uma categoria' : null,
                ),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _dataInicioValidade != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_dataInicioValidade!)
                        : '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Data de Início',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dataInicioValidade ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_dataInicioValidade ?? DateTime.now()),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _dataInicioValidade = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  validator: (value) =>
                      _dataInicioValidade == null ? 'Por favor, selecione a data de início' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _dataFimValidade != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_dataFimValidade!)
                        : '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Data de Validade',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dataFimValidade ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_dataFimValidade ?? DateTime.now()),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _dataFimValidade = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  validator: (value) =>
                      _dataFimValidade == null ? 'Por favor, selecione a data de validade' : null,
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 109, 94), // Cor de fundo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Borda arredondada
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Padding interno
                  ),
                  child: const Text(
                    'Salvar Notícia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Cor do texto
                    ),
                  ),
                ),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmar Exclusão'),
                            content: const Text('Você tem certeza que deseja excluir esta notícia?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          await _firestoreService.deleteNoticia(_noticiaId!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notícia excluída com sucesso!')),
                          );
                          Navigator.pop(context, true); // Retorna para a tela anterior
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao excluir notícia: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Cor do botão
                    ),
                    child: const Text('Deletar Notícia'),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1, // Índice da aba atual (1 para Criar)
        onTap: (index) {
          _navigateToScreen(context, index);
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/schedule');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }
}