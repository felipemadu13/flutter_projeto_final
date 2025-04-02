import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projeto_final/data/noticia_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_projeto_final/services/firestore_service.dart';
import 'package:intl/intl.dart';

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
  File? _selectedImage;
  DateTime? _dataInicioValidade;
  DateTime? _dataFimValidade;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  @override
  void initState() {
    super.initState();
    if (widget.noticia != null) {
      _tituloController.text = widget.noticia!['titulo'];
      _textoController.text = widget.noticia!['texto'];

      // Verificar se a data é do tipo Timestamp ou DateTime diretamente
      if (widget.noticia!['dataInicioValidade'] is Timestamp) {
        _dataInicioValidade = (widget.noticia!['dataInicioValidade'] as Timestamp).toDate();
      } else if (widget.noticia!['dataInicioValidade'] is DateTime) {
        _dataInicioValidade = widget.noticia!['dataInicioValidade'];
      }

      if (widget.noticia!['dataFimValidade'] != null) {
        if (widget.noticia!['dataFimValidade'] is Timestamp) {
          _dataFimValidade = (widget.noticia!['dataFimValidade'] as Timestamp).toDate();
        } else if (widget.noticia!['dataFimValidade'] is DateTime) {
          _dataFimValidade = widget.noticia!['dataFimValidade'];
        }
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
      final noticia = {
        "titulo": _tituloController.text,
        "texto": _textoController.text,
        "imagemUrl": _selectedImage != null ? _selectedImage!.path : widget.noticia?['imagemUrl'],
        "dataPublicacao": widget.noticia?['dataPublicacao'] ?? DateTime.now().toIso8601String(),
        "dataInicioValidade": _dataInicioValidade != null ? Timestamp.fromDate(_dataInicioValidade!) : Timestamp.now(),
        "dataFimValidade": _dataFimValidade != null ? Timestamp.fromDate(_dataFimValidade!) : null,
      };

      try {
        if (widget.noticia != null) {
          await _firestoreService.editNoticia(widget.noticia!['id'], noticia);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notícia atualizada com sucesso!')),
          );
        } else {
          String idUnico = DateTime.now().millisecondsSinceEpoch.toString();
          final novaNoticia = Noticia(
            idnoticia: int.parse(idUnico),
            idAutor: 1,
            titulo: _tituloController.text,
            texto: _textoController.text,
            imagens: [],
            categorias: [],
            dataInclusao: DateTime.now(),
            dataInicioValidade: _dataInicioValidade ?? DateTime.now(),
            dataFimValidade: _dataFimValidade,
          );

          await _firestoreService.createNoticia(novaNoticia, _selectedImage);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notícia criada com sucesso!')),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao salvar a notícia.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Notícia')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o título' : null,
                ),
                TextFormField(
                  controller: _textoController,
                  decoration: const InputDecoration(labelText: 'Texto'),
                  maxLines: 5,
                  validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o texto' : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Selecionar Imagem'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
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
