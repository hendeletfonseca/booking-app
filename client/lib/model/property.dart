class PropertySchema {
  final int? id;
  final int userId;
  final int addressId;
  final String title;
  final String description;
  final int number;
  final String? complement;
  final double price;
  final int maxGuest;
  final String thumbnail;

  PropertySchema({
    this.id,
    required this.userId,
    required this.addressId,
    required this.title,
    required this.description,
    required this.number,
    this.complement,
    required this.price,
    required this.maxGuest,
    required this.thumbnail,
  });

  // Converte o objeto PropertySchema para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'title': title,
      'description': description,
      'number': number,
      'complement': complement,
      'price': price,
      'max_guest': maxGuest,
      'thumbnail': thumbnail,
    };
  }

  // Cria um objeto PropertySchema a partir de um Map (JSON)
  factory PropertySchema.fromJson(Map<String, dynamic> json) {
    return PropertySchema(
      id: json['id'],
      userId: json['user_id'],
      addressId: json['address_id'],
      title: json['title'],
      description: json['description'],
      number: json['number'],
      complement: json['complement'],
      price: json['price'],
      maxGuest: json['max_guest'],
      thumbnail: json['thumbnail'],
    );
  }

  // Cria uma cópia do objeto PropertySchema com novos valores
  PropertySchema copy({
    int? id,
    int? userId,
    int? addressId,
    String? title,
    String? description,
    int? number,
    String? complement,
    double? price,
    int? maxGuest,
    String? thumbnail,
  }) {
    return PropertySchema(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      title: title ?? this.title,
      description: description ?? this.description,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      price: price ?? this.price,
      maxGuest: maxGuest ?? this.maxGuest,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
