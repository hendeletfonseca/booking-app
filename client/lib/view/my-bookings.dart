import 'dart:io';

import 'package:booking_app/database/db.dart';
import 'package:booking_app/model/user.dart';
import 'package:booking_app/model/images.dart';
import 'package:booking_app/model/address.dart';
import 'package:booking_app/model/booking.dart';
import 'package:booking_app/model/property.dart';
import 'package:booking_app/service/auth_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  UserSchema? _user;
  late Future<List<BookingSchema>> _bookingsFuture;


  @override
  void initState() {
    super.initState();
    _bookingsFuture = Future.value([]);
    _checkAndRequestPermission();
    _initializeData();

  }

  void _checkAndRequestPermission() async {
    if (await Permission.manageExternalStorage.isGranted) return;
    _showPermissionDialog();
  }

  Future<void> _getUserData() async {
    UserSchema? user = await AuthPreferences.getUserData();
    if (user != null) {
      setState(() {
        _user = user;
      });
    } else {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  void _initializeData() async {
    await _getUserData();
    if (_user != null) {
      setState(() {
        _bookingsFuture = BookingAppDB.instance.getBookingsByUser(_user!.id!);
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
        title: const Text('Minhas Reservas'),
      ),
      body: FutureBuilder<List<BookingSchema>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma reserva encontrada.'));
          } else {
            final bookings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reserva ${booking.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Check-in: ${booking.checkinDate}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Check-out: ${booking.checkoutDate}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Preço Total: R\$${booking.totalPrice}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}