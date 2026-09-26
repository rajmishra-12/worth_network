import 'dart:io';
import 'package:equatable/equatable.dart';

class EvidenceModel extends Equatable {
  final String type; // 'photo', 'document', 'audio', 'text', 'link'
  final String? url; // File storage URL or link URL
  final String? text; // Text proof note
  final String? title; // Web page title (for link evidence)
  final String? imageUrl; // Web page thumbnail image (for link evidence)
  final String? description; // Web page description (for link evidence)
  final File? localFile; // Local File object during uploading (transient)

  const EvidenceModel({
    required this.type,
    this.url,
    this.text,
    this.title,
    this.imageUrl,
    this.description,
    this.localFile,
  });

  EvidenceModel copyWith({
    String? type,
    String? url,
    String? text,
    String? title,
    String? imageUrl,
    String? description,
    File? localFile,
  }) {
    return EvidenceModel(
      type: type ?? this.type,
      url: url ?? this.url,
      text: text ?? this.text,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      localFile: localFile ?? this.localFile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (url != null) 'url': url,
      if (text != null) 'text': text,
      if (title != null) 'title': title,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
    };
  }

  factory EvidenceModel.fromMap(Map<String, dynamic> map) {
    return EvidenceModel(
      type: map['type'] ?? 'text',
      url: map['url'],
      text: map['text'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      description: map['description'],
    );
  }

  @override
  List<Object?> get props => [
        type,
        url,
        text,
        title,
        imageUrl,
        description,
        localFile,
      ];
}
