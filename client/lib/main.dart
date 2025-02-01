import 'package:flutter/material.dart';
import 'package:booking_app/service/auth_preferences.dart';
import 'package:booking_app/routes/app_routes.dart';
import 'package:booking_app/view/home_page.dart'; // Importe a HomePage
import 'package:booking_app/sample_data.dart';

import 'database/db.dart'; // Importe o arquivo de dados de teste

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o banco de dados
  await BookingAppDB.instance.database;
  print("bd ok");

  // Insere os dados de teste (se necessário)
  try {
    await insertSampleData();
  } catch (e) {
    print("Erro ao inserir dados de teste: $e");
  }


  // Verifica se o usuário está autenticado
  bool isAuthenticated = await AuthPreferences.isAuthenticated();
  String initialRoute = isAuthenticated ? '/home' : '/login';


  runApp(
    MyApp(
      initialRoute: initialRoute,
    ),
  );
}
class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: initialRoute,
    );
  }
}