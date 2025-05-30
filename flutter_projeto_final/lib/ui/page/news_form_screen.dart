import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/data/imagem_model.dart';
import 'package:flutter_projeto_final/data/noticia_model.dart';
import 'package:flutter_projeto_final/data/categoria_model.dart';
import 'package:flutter_projeto_final/ui/widgets/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:textfield_tags/textfield_tags.dart';


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
  late TextfieldTagsController<String> textfieldTagsController;

  File? _selectedImage;
  final String _defaultImagePath = 'assets/images/default_image.jpg'; 
  DateTime? _dataInicioValidade;
  DateTime? _dataFimValidade;
  final FirestoreService _firestoreService = FirestoreService();
  bool _criandoCategoria = false;
  List<Map<String, dynamic>> _categorias = [];
  List<String> _categoriaSelecionada = [];
  bool _isEditing = false; 
  int? _noticiaId; 
  String? _imageUrl;
  List<String> _todasCategoriasNomes = [];
  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    textfieldTagsController = TextfieldTagsController<String>();

    
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

     
      final categoriasDaNoticia = widget.noticia!['categorias'] as List<dynamic>? ?? [];
      print("Categorias da notícia: $categoriasDaNoticia");
      if (categoriasDaNoticia.isNotEmpty) {
        int idCategoriaNoticia = categoriasDaNoticia[0];
        String categoriaNome = _categorias.firstWhere(
              (categoria) => categoria['idCategoria'] == idCategoriaNoticia,
          orElse: () => {'Nome': ''},
        )['Nome'] as String;
        if (categoriaNome.isNotEmpty) {
          _categoriaSelecionada = [categoriaNome];
        }
      }


    }
  }


  Future<void> _carregarCategorias() async {
    try {
      List<Categoria> categorias = await _firestoreService.fetchCategorias();
      setState(() {
        _categorias = categorias.map((c) => {'idCategoria': c.idCategoria, 'Nome': c.Nome}).toList();
        _todasCategoriasNomes = _categorias.map((c) => c['Nome'] as String).toList();
      });

      if (_isEditing) {
        _definirCategoriaNoticia();
      }
    } catch (e) {
      print("Erro ao carregar categorias");
    }
  }


  void _definirCategoriaNoticia() {
    if (widget.noticia != null) {
      final categoriasDaNoticia = widget.noticia!['categorias'] as List<dynamic>? ?? [];
      if (categoriasDaNoticia.isNotEmpty) {
        final categoriasEncontradas = _categorias
            .where((c) => categoriasDaNoticia.contains(c['idCategoria']))
            .toList();

        setState(() {
          _categoriaSelecionada = categoriasEncontradas
              .map((c) => c['Nome'] as String)
              .where((nome) => nome.isNotEmpty)
              .toList();
        });


      }
    }
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

     
      if (_dataInicioValidade != null &&
          _dataFimValidade != null &&
          _dataInicioValidade!.isAfter(_dataFimValidade!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A data de início não pode ser maior que a data de fim'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? novaImagemUrl;
      if (_selectedImage != null) {
        novaImagemUrl = await _firestoreService.uploadImageToImgBB(_selectedImage!);
        if (novaImagemUrl == null) {
          throw Exception("Falha ao fazer upload da imagem");
        }
      }

      try {
        List<int> imagensAtualizadas = [];
        List<Map<String, dynamic>> _categorias = [];
        
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Usuário não autenticado.');
        }

        final String uid = currentUser.uid;

        if (_isEditing && widget.noticia != null) {
          imagensAtualizadas = List<int>.from(widget.noticia!['imagens'] ?? []);
        }

        if (_selectedImage != null) {
          
          String? urlImagem = await _firestoreService.uploadImageToImgBB(
              _selectedImage!);
          if (urlImagem == null) throw Exception("Falha no upload da imagem");

        
          int novoIdImagem = DateTime
              .now()
              .millisecondsSinceEpoch; 
          await _firestoreService.salvarImagem(
            ImagemModel(
              idImagem: novoIdImagem,
              arquivoImagem: urlImagem,
              dataInclusao: DateTime.now(),
            ),
          );
          imagensAtualizadas.add(novoIdImagem);
        }


        
        List<int> categoriasSelecionadas = [];
        for (var categoriaNome in _categoriaSelecionada) {
          
          var categoriaExistente = _categorias.firstWhere(
                (c) => c['Nome'] == categoriaNome,
            orElse: () => <String, dynamic>{'idCategoria': null},
          );

          if (categoriaExistente['idCategoria'] != null) {
            categoriasSelecionadas.add(categoriaExistente['idCategoria'] as int);
          } else {
            
            try {
              final novaCategoriaId = await _firestoreService.getCategoriaIdByNome(categoriaNome);
              categoriasSelecionadas.add(novaCategoriaId);

             
              setState(() {
                _categorias.add({
                  'idCategoria': novaCategoriaId,
                  'Nome': categoriaNome
                });
              });
            } catch (e) {
              print('Erro ao processar categoria $categoriaNome');
              
            }
          }
        }

        if (categoriasSelecionadas.isEmpty) {
          throw Exception("Nenhuma categoria selecionada.");
        }

        if (_isEditing) {
          
          Map<String, dynamic> updateData = {
            'titulo': _tituloController.text,
            'texto': _textoController.text,
            'imagens': imagensAtualizadas,
            'dataInicioValidade': _dataInicioValidade,
            'dataFimValidade': _dataFimValidade,
            'categorias': categoriasSelecionadas,
          };


          
          if (widget.noticia != null && widget.noticia!.containsKey('dataInclusao')) {
            if (widget.noticia!['dataInclusao'] is Timestamp) {
              updateData['dataInclusao'] = (widget.noticia!['dataInclusao'] as Timestamp).toDate();
            } else if (widget.noticia!['dataInclusao'] is DateTime) {
              updateData['dataInclusao'] = widget.noticia!['dataInclusao'];
            } else {
              
              updateData['dataInclusao'] = DateTime.now();
            }
          } else {
            
            updateData['dataInclusao'] = DateTime.now();
          }

          await _firestoreService.editNoticia(_noticiaId!, updateData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notícia atualizada com sucesso!')),
          );
        } else {
          
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
          SnackBar(content: Text('Erro ao salvar notícia $e')),
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
                
                GestureDetector(
                  onTap: _pickImage,
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
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _todasCategoriasNomes.where((categoria) =>
                        categoria.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    );
                  },
                  onSelected: (String selection) {
                    setState(() {
                      if (!_categoriaSelecionada.contains(selection)) {
                        _categoriaSelecionada.add(selection);
                        textfieldTagsController.addTag(selection);
                      }
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Digite uma categoria",
                        hintText: "Comece a digitar para ver sugestões",
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty && !_categoriaSelecionada.contains(value)) {
                          setState(() {
                            _categoriaSelecionada.add(value);
                            textfieldTagsController.addTag(value);
                          });
                        }
                        textEditingController.clear();
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 8,
                  children: _categoriaSelecionada.map(
                        (tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          _categoriaSelecionada.remove(tag);
                          textfieldTagsController.removeTag(tag);
                        });
                      },
                    ),
                  ).toList(),
                ),


                ElevatedButton(
                  onPressed: () => _selectDateTime(context, true),
                  child: Text(_dataInicioValidade == null
                      ? 'Selecionar Data e Hora de Início'
                      : 'Início: ${DateFormat('dd/MM/yyyy HH:mm').format(_dataInicioValidade!)}'),
                ),
                ElevatedButton(
                  onPressed: () => _selectDateTime(context, false),
                  child: Text(_dataFimValidade == null
                      ? 'Selecionar Data e Hora de Fim'
                      : 'Fim: ${DateFormat('dd/MM/yyyy HH:mm').format(_dataFimValidade!)}'),
                ),
               
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 109, 94), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), 
                  ),
                  child: const Text(
                    'Salvar Notícia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
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
                          Navigator.pop(context, true); 
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao excluir notícia')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, 
                    ),
                    child: const Text('Deletar Notícia'),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1, 
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