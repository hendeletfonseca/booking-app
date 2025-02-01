import 'package:flutter/material.dart';
import 'package:admin/service/auth_preferences.dart';
import 'package:admin/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String initialRoute;
  bool isAuthenticated = await AuthPreferences.isAuthenticated();

  initialRoute = isAuthenticated ? '/home' : '/login';
  initialRoute = '/home';

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
