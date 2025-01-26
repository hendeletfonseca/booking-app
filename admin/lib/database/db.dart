import 'package:admin/model/user.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

Future<void> _createDatabase(Database db, int version) async {
  return await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username VARCHAR NOT NULL,
          email VARCHAR NOT NULL UNIQUE,
          password VARCHAR NOT NULL
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
    // Obtém o diretório público no armazenamento externo
    final directory = Directory('/storage/emulated/0/BookingApp');

    // Cria o diretório se ele não existir
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final path = '${directory.path}/shared_data.db';
    print("Shared database path: $path");

    // Inicializa o banco de dados no caminho compartilhado
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
}