import 'package:admin/model/address.dart';
import 'package:admin/model/images.dart';
import 'package:admin/model/property.dart';
import 'package:admin/model/user.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

Future<void> _createDatabase(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR NOT NULL,
      email VARCHAR NOT NULL UNIQUE,
      password VARCHAR NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS address(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cep VARCHAR NOT NULL UNIQUE,
      logradouro VARCHAR NOT NULL,
      bairro VARCHAR NOT NULL,
      localidade VARCHAR NOT NULL,
      uf VARCHAR NOT NULL,
      estado VARCHAR NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS property(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      address_id INTEGER NOT NULL,
      title VARCHAR NOT NULL,
      description VARCHAR NOT NULL,
      number INTEGER NOT NULL,
      complement VARCHAR,
      price REAL NOT NULL,
      max_guest INTEGER NOT NULL,
      thumbnail VARCHAR NOT NULL,
      FOREIGN KEY(user_id) REFERENCES user(id),
      FOREIGN KEY(address_id) REFERENCES address(id)
    );        
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS images(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      property_id INTEGER NOT NULL,
      path VARCHAR NOT NULL,    
      FOREIGN KEY(property_id) REFERENCES property(id)
    );
  ''');

  await db.execute('''
    CREATE TABLE booking(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     user_id INTEGER NOT NULL,
     property_id INTEGER NOT NULL,
     checkin_date VARCHAR NOT NULL,
     checkout_date VARCHAR NOT NULL,
     total_days INTEGER NOT NULL,
     total_price REAL NOT NULL,
     amount_guest INTEGER NOT NULL,
     rating REAL,
     FOREIGN KEY(user_id) REFERENCES user(id),
     FOREIGN KEY(property_id) REFERENCES property(id) ON DELETE CASCADE
    )
  ''');
}

class BookingAppDB {
  static final BookingAppDB instance = BookingAppDB._internal();

  static Database? _database;

  BookingAppDB._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = Directory('/storage/emulated/0/BookingApp');

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final path = '${directory.path}/shared_data.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<UserSchema?> insertUser(UserSchema user) async {
    final db = await instance.database;
    final users = await db.query('user');

    if (users.any((element) => element['email'] == user.email)) {
      return null;
    }

    final id = await db.insert('user', user.toJson());
    return user.copy(id: id);
  }

  Future<UserSchema?> getUser(int id) async {
    final db = await instance.database;
    final users = await db.query('user');

    if (users.any((element) => element['id'] == id)) {
      final user = users.firstWhere((element) => element['id'] == id);
      return UserSchema.fromJson(user);
    }

    return null;
  }

  Future<UserSchema?> fetchUserByEmail(String email, String password) async {
    final db = await instance.database;
    final users = await db.query('user');

    if (users.any((element) => element['email'] == email)) {
      final user = users.firstWhere((element) => element['email'] == email);
      if (user['password'] == password) return UserSchema.fromJson(user);
    }

    return null;
  }

  Future<Address?> getAddress(int id) async {
    final db = await instance.database;
    final addresses = await db.query(
      'address',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (addresses.isNotEmpty) {
      return Address.fromJson(addresses.first);
    }
    return null;
  }

  Future<Address?> fetchAddressByCEP(String cep) async {
    final db = await instance.database;
    final addresses = await db.query('address');

    if (addresses.any((element) => element['cep'] == cep)) {
      final address = addresses.firstWhere((element) => element['cep'] == cep);
      return Address.fromJson(address);
    }

    return null;
  }

  Future<Address?> insertAddress(Address address) async {
    final db = await instance.database;
    final addresses = await db.query('address');

    if (addresses.any((element) => element['cep'] == address.cep)) {
      final dbAddress =
          addresses.firstWhere((element) => element['cep'] == address.cep);
      return Address.fromJson(dbAddress);
    }

    final id = await db.insert('address', address.toJson());
    return address.copy(id: id);
  }

  Future<bool> cepUsed(String cep) async {
    final db = await instance.database;
    final properties = await db.query('property');

    return properties.any((element) => element['cep'] == cep);
  }

  Future<PropertySchema> insertProperty(PropertySchema property) async {
    final db = await instance.database;
    final id = await db.insert('property', property.toJson());
    return property.copy(id: id);
  }

  Future<List<PropertySchema>> getAllProperties() async {
    final db = await instance.database;
    final properties = await db.query('property');
    return properties.map((json) => PropertySchema.fromJson(json)).toList();
  }

  Future<List<ImageSchema>> getImagesByProperty(int propertyId) async {
    final db = await instance.database;
    final images = await db.query(
      'images',
      where: 'property_id = ?',
      whereArgs: [propertyId],
    );
    return images.map((json) => ImageSchema.fromJson(json)).toList();
  }

  Future<void> deleteProperty(int id) async {
    final db = await instance.database;
    await db.delete(
      'property',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
