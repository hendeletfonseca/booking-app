import 'package:booking_app/database/db.dart';
import 'package:booking_app/model/user.dart';
import 'package:booking_app/service/auth_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem vindo de volta!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entre na sua conta para continuar!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock,
                obscureText: _isObscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLoading = true;
                          });
                          _login().then((logged) {
                            setState(() {
                              _isLoading = false;
                            });
                            if (logged) {
                              Navigator.popAndPushNamed(context, '/home');
                            }
                            else {
                              _showErrorMensage();
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                  child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    // Margem à direita
                    child: Text(
                      'Ainda não tem uma conta?',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/register');
                      // requestPermissions().then((_) {
                      //   print("Permissions granted");
                      // });
                    },
                    child: const Text(
                      'Registre-se',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Future<bool> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    BookingAppDB db = BookingAppDB.instance;
    UserSchema? user = await db.fetchUserByEmail(email, password);

    if (user != null) {
      AuthPreferences.saveInformation(user.id!);
      return true;
    }

    return false;
  }

  void _showErrorMensage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email ou senha incorreto.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> requestPermissions() async {
  final status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    throw Exception("Storage permission not granted");
  }
}

}
