import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/user.dart';
import '../service/auth_preferences.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  UserSchema? _user;

  String welcomeText = 'Welcome to the home page';

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  void _checkAndRequestPermission() async {
    if (await Permission.manageExternalStorage.isGranted) return;
    _showPermissionDialog();
  }

  void _getUserData() async {
    UserSchema? user = await AuthPreferences.getUserData();
    if (user != null) {
      setState(() {
        _user = user;
        welcomeText = 'Welcome ${_user!.username}';
      });
    } else {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  Future<void> _getPermissions() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      throw Exception("Storage permission not granted");
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissão Necessária'),
          content: const Text(
              'O aplicativo precisa de permissão para acessar o armazenamento. Deseja conceder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getPermissions().then((_) {
                  _getUserData();
                }).catchError((error) {
                  _showPermissionDialog();
                });
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              welcomeText,
            ),
            ElevatedButton(
              onPressed: () {
                _signOut().then((_) {
                  Navigator.popAndPushNamed(context, '/login');
                });
              },
              child: const Text(
                'DESLOGAR',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthPreferences.removeAuthenticationInfo();
  }
}
