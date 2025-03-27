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
  DateTime? _dataPublicacao;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final noticia = {
        "titulo": _tituloController.text,
        "texto": _textoController.text,
        "imagemUrl": _imagemUrlController.text,
        "dataPublicacao": _dataPublicacao?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/noticias'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(noticia),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notícia cadastrada com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar a notícia.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Notícia'),
        backgroundColor: Color.fromARGB(255, 41, 109, 94),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _textoController,
                decoration: InputDecoration(labelText: 'Texto'),
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
                decoration: InputDecoration(labelText: 'URL da Imagem'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a URL da imagem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _dataPublicacao == null
                        ? 'Data de Agendamento: Não selecionada'
                        : 'Data de Agendamento: ${_dataPublicacao!.toLocal()}'.split(' ')[0],
                  ),
                  Spacer(),
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
                          _dataPublicacao = selectedDate;
                        });
                      }
                    },
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 41, 109, 94),
                ),
                child: Text('Salvar Notícia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}