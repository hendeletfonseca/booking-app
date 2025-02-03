import 'package:booking_app/model/user.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import '../model/address.dart';
import '../model/booking.dart';
import '../model/images.dart';
import '../model/property.dart';

Future<void> _createDatabase(Database db, int version) async {
  await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR NOT NULL,
          email VARCHAR NOT NULL UNIQUE,
          password VARCHAR NOT NULL
        )
      ''');

  await db.execute('''
        CREATE TABLE address(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cep VARCHAR NOT NULL UNIQUE,
        logradouro VARCHAR NOT NULL,
        bairro VARCHAR NOT NULL,
        localidade VARCHAR NOT NULL,
        uf VARCHAR NOT NULL,
        estado VARCHAR NOT NULL
      )
      ''');
  print("Tabela address criada.");


  await db.execute('''
      CREATE TABLE property(
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
)
  ''');

  await db.execute('''
    CREATE TABLE images(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     property_id INTEGER NOT NULL,
     path VARCHAR NOT NULL,
     FOREIGN KEY(property_id) REFERENCES property(id)
   )
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
    // Obtém o diretório público no armazenamento externo
    final directory = Directory('/storage/emulated/0/BookingApp');

    // Cria o diretório se ele não existir
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final path = '${directory.path}/shared_data.db';

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

  // Método para buscar todas as propriedades
  Future<List<PropertySchema>> getAllProperties() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT property.*, AVG(booking.rating) AS average_rating
    FROM property
    LEFT JOIN booking ON property.id = booking.property_id
    GROUP BY property.id
    ORDER BY average_rating DESC
  ''');

    return result.map((json) => PropertySchema.fromJson(json)).toList();
  }


  // Método para buscar um endereço por ID
  Future<AddressSchema?> getAddress(int id) async {
    final db = await instance.database;
    final addresses = await db.query(
      'address',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (addresses.isNotEmpty) {
      return AddressSchema.fromJson(addresses.first);
    }
    return null;
  }

  // Método para buscar imagens de uma propriedade
  Future<List<ImageSchema>> getImagesByProperty(int propertyId) async {
    final db = await instance.database;
    final images = await db.query(
      'images',
      where: 'property_id = ?',
      whereArgs: [propertyId],
    );
    return images.map((json) => ImageSchema.fromJson(json)).toList();
  }

  // Método para buscar reservas por usuário
  Future<List<BookingSchema>> getBookingsByUser(int userId) async {
    final db = await instance.database;
    final bookings = await db.query(
      'booking',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return bookings.map((json) => BookingSchema.fromJson(json)).toList();
  }

  // Método para inserir uma reserva
  Future<int> insertBooking(BookingSchema booking) async {
    final db = await instance.database;
    return await db.insert('booking', booking.toJson());
  }

  // Método para atualizar uma reserva
  Future<int> updateBooking(BookingSchema booking) async {
    final db = await instance.database;
    return await db.update(
      'booking',
      booking.toJson(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  // Método para remover uma reserva
  Future<int> deleteBooking(int id) async {
    final db = await instance.database;
    return await db.delete(
      'booking',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //média dos ratings por propriedade
  Future<double> getAverageRatingForProperty(int propertyId) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
    SELECT AVG(rating) AS average_rating
    FROM booking
    WHERE property_id = ? AND rating IS NOT NULL
    ''',
      [propertyId],
    );

    if (result.isNotEmpty && result.first['average_rating'] != null) {
      return result.first['average_rating'] as double;
    }

    return 0;
  }

  // Método para checar conflito em reservas
  Future<bool> checkBookingConflict(int? propertyId, DateTime checkin, DateTime checkout) async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT * FROM booking 
      WHERE property_id = ? 
      AND (
        (checkin_date BETWEEN ? AND ?) 
        OR (checkout_date BETWEEN ? AND ?) 
        OR (? BETWEEN checkin_date AND checkout_date)
        OR (? BETWEEN checkin_date AND checkout_date)
      )
    ''', [propertyId, checkin.toIso8601String(), checkout.toIso8601String(), 
        checkin.toIso8601String(), checkout.toIso8601String(), 
        checkin.toIso8601String(), checkout.toIso8601String()]);

    return result.isNotEmpty;
  }

  // Método para fazer uma reserva
  Future<String> makeBooking({
    required int userId,
    required int propertyId,
    required DateTime checkin,
    required DateTime checkout,
    required int guests,
    required double pricePerNight,
    required double rating,
  }) async {
    final db = await instance.database;

    bool conflict = await checkBookingConflict(propertyId, checkin, checkout);
    
    if (conflict) {
      return "Erro: Já existe uma reserva para essas datas.";
    }

    int totalDays = checkout.difference(checkin).inDays;
    double totalPrice = totalDays * pricePerNight;

    String checkinStr = checkin.toIso8601String().split("T")[0];
    String checkoutStr = checkout.toIso8601String().split("T")[0];

    BookingSchema booking = BookingSchema(
      userId: userId,
      propertyId: propertyId,
      checkinDate: checkinStr,
      checkoutDate: checkoutStr,
      totalDays: totalDays,
      totalPrice: totalPrice,
      amountGuest: guests,
      rating: rating,
    );

    await db.insert('booking', booking.toJson());
    return "Reserva feita com sucesso!";
  }
}