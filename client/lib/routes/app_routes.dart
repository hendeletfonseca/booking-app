import 'package:booking_app/view/home_page.dart';
import 'package:booking_app/view/login_page.dart';
import 'package:booking_app/view/register_page.dart';
import 'package:flutter/material.dart';

final routes = {
  '/home': (BuildContext context) => const HomePage(),
  '/login': (BuildContext context) => const LoginPage(),
  '/register': (BuildContext context) => const RegisterPage(),
  //'/register': (BuildContext context) => const BookPage(),
};