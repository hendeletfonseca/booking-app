import 'package:admin/view/home_page.dart';
import 'package:admin/view/login_page.dart';
import 'package:admin/view/register_page.dart';
import 'package:flutter/material.dart';

final routes = {
  '/home': (BuildContext context) => const HomePage(),
  '/login': (BuildContext context) => const LoginPage(),
  '/register': (BuildContext context) => const RegisterPage(),
};