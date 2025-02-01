class ImageSchema {
  final int? id;
  final int propertyId;
  final String path;

  ImageSchema({
    this.id,
    required this.propertyId,
    required this.path,
  });

  // Converte o objeto ImageSchema para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'path': path,
    };
  }

  // Cria um objeto ImageSchema a partir de um Map (JSON)
  factory ImageSchema.fromJson(Map<String, dynamic> json) {
    return ImageSchema(
      id: json['id'],
      propertyId: json['property_id'],
      path: json['path'],
    );
  }

  // Cria uma cópia do objeto ImageSchema com novos valores
  ImageSchema copy({
    int? id,
    int? propertyId,
    String? path,
  }) {
    return ImageSchema(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      path: path ?? this.path,
    );
  }
}