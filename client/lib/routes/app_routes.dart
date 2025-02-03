import 'package:booking_app/view/home_page.dart';
import 'package:booking_app/view/login_page.dart';
import 'package:booking_app/view/register_page.dart';
import 'package:booking_app/view/book_page.dart';
import 'package:flutter/material.dart';
import '../view/reserves.dart';
import '../view/my-bookings.dart';

final routes = {
  '/home': (BuildContext context) => const HomePage(),
  '/login': (BuildContext context) => const LoginPage(),
  '/register': (BuildContext context) => const RegisterPage(),
  '/book-page': (BuildContext context) => const BookPage(),
  '/my-bookings':  (BuildContext context) => const MyBookingsPage(),
  '/reserves':  (BuildContext context) => const Reserves(),
};