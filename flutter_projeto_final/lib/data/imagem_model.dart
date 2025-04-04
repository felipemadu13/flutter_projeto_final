import 'package:cloud_firestore/cloud_firestore.dart';

class ImagemModel {
  final int idImagem;
  final String arquivoImagem;
  final DateTime dataInclusao;

  ImagemModel({
    required this.idImagem,
    required this.arquivoImagem,
    required this.dataInclusao,
  });


  factory ImagemModel.fromMap(Map<String, dynamic> map, int id) {
    return ImagemModel(
      idImagem: id,
      arquivoImagem: map['arquivoImagem'] ?? '',
      dataInclusao: (map['dataInclusao'] as Timestamp).toDate(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'idImagem': idImagem,
      'arquivoImagem': arquivoImagem,
      'dataInclusao': dataInclusao,
    };
  }
}
