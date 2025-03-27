import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsFormScreen extends StatefulWidget {
  const NewsFormScreen({super.key});

  @override
  _NewsFormScreen createState() => _NewsFormScreen();
}

class _NewsFormScreen extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  final TextEditingController _imagemUrlController = TextEditingController();
  DateTime? _dataInicioValidade;
  DateTime? _dataFimValidade;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final noticia = {
        "titulo": _tituloController.text,
        "texto": _textoController.text,
        "imagemUrl": _imagemUrlController.text,
        "dataPublicacao": DateTime.now().toIso8601String(),
        'dataInicioValidade': _dataInicioValidade?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'dataFimValidade': _dataFimValidade?.toIso8601String() ?? "",
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/noticias'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(noticia),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notícia cadastrada com sucesso!')),
        );

        // Atualiza a página anterior e navega para a aba "Notícias"
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar a notícia.')),
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
                TextFormField(
                  controller: _imagemUrlController,
                  decoration: const InputDecoration(labelText: 'URL da Imagem'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a URL da imagem';
                    }
                    return null;
                  },
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