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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserSchema? _user;
  String welcomeText = 'Welcome to the home page';
  late Future<List<PropertySchema>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    _propertiesFuture = BookingAppDB.instance.getAllProperties();
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

  final List<String> imagePaths = [
    'assets/images/chale_ex_1.jpg',
    'assets/images/chale_ex_2.jpg',
    'assets/images/chale_ex_3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore novas experiências!')),
      body: FutureBuilder<List<PropertySchema>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma propriedade encontrada.'));
          } else {
            final properties = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return FutureBuilder<List<ImageSchema>>(
                  future: BookingAppDB.instance.getImagesByProperty(property.id!),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (imageSnapshot.hasError) {
                      return Text('Erro ao carregar imagens: ${imageSnapshot.error}');
                    } else {
                      final images = imageSnapshot.data ?? [];
                      return FutureBuilder<AddressSchema?>(
                        future: BookingAppDB.instance.getAddress(property.addressId),
                        builder: (context, addressSnapshot) {
                          if (addressSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (addressSnapshot.hasError) {
                            return Text('Erro ao carregar endereço: ${addressSnapshot.error}');
                          } else if (!addressSnapshot.hasData) {
                            return const Text('Endereço não encontrado.');
                          } else {
                            final address = addressSnapshot.data!;
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Carrossel de imagens
                                    SizedBox(
                                      height: 180,
                                      child: PageView.builder(
                                        itemCount: images.length,
                                        controller: PageController(viewportFraction: 0.8),
                                        itemBuilder: (context, pageIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.asset(
                                                images[pageIndex].path,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Localidade e UF
                                    Text(
                                      '${address.localidade}, ${address.uf}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    // Preço da propriedade
                                    Text(
                                      'R\$${property.price} noite',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}