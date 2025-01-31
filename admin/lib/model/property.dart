import 'package:admin/model/address.dart';
import 'package:admin/model/user.dart';

class PropertySchema {
  final int? id;
  final int userId;
  final int addressId;
  final String title;
  final String description;
  final int number;
  final String? complement;
  final double price;
  final int maxGuests;
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
    required this.maxGuests,
    required this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'address_id': addressId,
      'title': title,
      'description': description,
      'number': number,
      'complement': complement,
      'price': price,
      'max_guest': maxGuests,
      'thumbnail': thumbnail,
    };
  }

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
      maxGuests: json['max_guest'],
      thumbnail: json['thumbnail'],
    );
  }

  PropertySchema copy({
    int? id,
    int? userId,
    int? addressId,
    String? title,
    String? description,
    int? number,
    String? complement,
    double? price,
    int? maxGuests,
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
      maxGuests: maxGuests ?? this.maxGuests,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  String toString() {
    return 'PropertySchema{id: $id, userId: $userId, addressId: $addressId, title: $title, description: $description, number: $number, complement: $complement, price: $price, maxGuests: $maxGuests, thumbnail: $thumbnail}';
  }

}

class Property {
  final int id;
  final UserSchema user;
  final Address address;
  final String title;
  final String description;
  final int number;
  final String? complement;
  final double price;
  final int maxGuests;
  final String thumbnail;

  Property({
    required this.id,
    required this.user,
    required this.address,
    required this.title,
    required this.description,
    required this.number,
    this.complement,
    required this.price,
    required this.maxGuests,
    required this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'address': address.toJson(),
      'title': title,
      'description': description,
      'number': number,
      'complement': complement,
      'price': price,
      'max_guest': maxGuests,
      'thumbnail': thumbnail,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      user: UserSchema.fromJson(json['user']),
      address: Address.fromJson(json['address']),
      title: json['title'],
      description: json['description'],
      number: json['number'],
      complement: json['complement'],
      price: json['price'],
      maxGuests: json['max_guest'],
      thumbnail: json['thumbnail'],
    );
  }

  Property copy({
    int? id,
    UserSchema? user,
    Address? address,
    String? title,
    String? description,
    int? number,
    String? complement,
    double? price,
    int? maxGuests,
    String? thumbnail,
  }) {
    return Property(
      id: id ?? this.id,
      user: user ?? this.user,
      address: address ?? this.address,
      title: title ?? this.title,
      description: description ?? this.description,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      price: price ?? this.price,
      maxGuests: maxGuests ?? this.maxGuests,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  String toString() {
    return 'Property{id: $id, user: $user, address: $address, title: $title, description: $description, number: $number, complement: $complement, price: $price, maxGuests: $maxGuests, thumbnail: $thumbnail}';
  }

}