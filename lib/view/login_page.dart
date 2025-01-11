import 'package:booking_app/service/auth_preferences.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // fullname
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'FullName',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
              obscureText: _isObscure,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _login().then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pushNamed(context, '/home');
                });
              },
              child: const Text('Login'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
  String fullName = _fullNameController.text;
  String email = _emailController.text;
  String password = _passwordController.text; 

  await AuthPreferences.saveInformation(fullName, email, password);
}
}

