import 'package:admin/model/user.dart';
import 'package:admin/service/auth_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserSchema? _user;

  final TextEditingController _cepController = TextEditingController();

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  void _checkAndRequestPermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      _getUserData();
      return;
    }
    _showPermissionDialog();
  }

  void _getUserData() async {
    UserSchema? user = await AuthPreferences.getUserData();
    if (user != null) {
      setState(() {
        _user = user;
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
        title: const Text('Home Page'),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Messages',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-property');
                },
                child: const Icon(Icons.add),
              ),
            ],
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
    );
  }

  Future<void> _signOut() async {
    await AuthPreferences.removeAuthenticationInfo();
  }
}
