import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> insertSampleData() async {
  // Abre o banco de dados
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'shared_data.db');
  final db = await openDatabase(path);

  // Insere o endereço
  await db.rawInsert('''
    INSERT INTO address (cep, logradouro, bairro, localidade, uf, estado)
    VALUES (?, ?, ?, ?, ?, ?)
  ''', ['12345-678', 'Rua das Flores', 'Centro', 'Petrópolis', 'RJ', 'Rio de Janeiro']);

  // Insere a propriedade
  await db.rawInsert('''
    INSERT INTO property (user_id, address_id, title, description, number, complement, price, max_guest, thumbnail)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''', [1, 1, 'Chalé aconchegante em Petrópolis', 'Um chalé perfeito para relaxar nas montanhas.', 123, 'Chalé 1', 500.0, 4, 'assets/images/chale_ex_1.jpg']);

  // Insere as imagens da propriedade
  await db.rawInsert('''
    INSERT INTO images (property_id, path)
    VALUES (?, ?)
  ''', [1, 'assets/images/chale_ex_1.jpg']);

  await db.rawInsert('''
    INSERT INTO images (property_id, path)
    VALUES (?, ?)
  ''', [1, 'assets/images/chale_ex_2.jpg']);

  await db.rawInsert('''
    INSERT INTO images (property_id, path)
    VALUES (?, ?)
  ''', [1, 'assets/images/chale_ex_3.jpg']);

  print('Dados de teste inseridos com sucesso!');
}