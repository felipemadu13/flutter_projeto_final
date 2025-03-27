import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? noticia; // Notícia opcional para edição

  const NewsFormScreen({super.key, this.noticia});

  @override
  _NewsFormScreenState createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  File? _selectedImage;
  DateTime? _dataInicioValidade;
  DateTime? _dataFimValidade;

  @override
  void initState() {
    super.initState();

    // Preenche os campos se estiver editando
    if (widget.noticia != null) {
      _tituloController.text = widget.noticia!['titulo'];
      _textoController.text = widget.noticia!['texto'];
      _dataInicioValidade = DateTime.parse(widget.noticia!['dataInicioValidade']);
      _dataFimValidade = widget.noticia!['dataFimValidade'] != null &&
              widget.noticia!['dataFimValidade'].isNotEmpty
          ? DateTime.parse(widget.noticia!['dataFimValidade'])
          : null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final noticia = {
        "titulo": _tituloController.text,
        "texto": _textoController.text,
        "imagemUrl": _selectedImage != null ? _selectedImage!.path : widget.noticia?['imagemUrl'],
        "dataPublicacao": widget.noticia?['dataPublicacao'] ?? DateTime.now().toIso8601String(),
        'dataInicioValidade': _dataInicioValidade?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'dataFimValidade': _dataFimValidade?.toIso8601String() ?? "",
      };

      final url = widget.noticia != null
          ? 'http://10.0.2.2:3000/noticias/${widget.noticia!['id']}' // Atualiza notícia existente
          : 'http://10.0.2.2:3000/noticias'; // Cria nova notícia

      final response = await (widget.noticia != null
          ? http.put(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(noticia))
          : http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(noticia)));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.noticia != null ? 'Notícia atualizada com sucesso!' : 'Notícia criada com sucesso!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao salvar a notícia.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Notícia'),
        backgroundColor: const Color.fromARGB(255, 41, 109, 94),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o título';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _textoController,
                  decoration: const InputDecoration(labelText: 'Texto'),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o texto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_selectedImage != null)
                      Expanded(
                        child: Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Erro ao carregar a imagem');
                          },
                        ),
                      )
                    else
                      const Expanded(
                        child: Text('Nenhuma imagem selecionada'),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Selecionar Imagem'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _dataInicioValidade == null
                            ? 'Início da Validade: Não selecionada'
                            : 'Início da Validade: ${_dataInicioValidade!.toLocal()}'.split(' ')[0],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _dataInicioValidade = selectedDate;
                          });
                        }
                      },
                      child: const Text('Selecionar Início'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _dataFimValidade == null
                            ? 'Fim da Validade: Não selecionada'
                            : 'Fim da Validade: ${_dataFimValidade!.toLocal()}'.split(' ')[0],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _dataFimValidade = selectedDate;
                          });
                        }
                      },
                      child: const Text('Selecionar Fim'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 109, 94),
                  ),
                  child: const Text('Salvar Notícia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}