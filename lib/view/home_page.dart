import 'package:booking_app/model/user.dart';
import 'package:booking_app/service/auth_preferences.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  UserSchema? _user;

  String welcomeText = 'Welcome to the home page';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    UserSchema? user = await AuthPreferences.getUserData();
    if (user != null) {
      setState(() {
        _user = user;
        welcomeText = 'Welcome ${_user!.username}';
      });
  }
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
          ],
        ),
      ),
    );
  }
}