import 'dart:io';

import 'package:admin/database/db.dart';
import 'package:admin/model/address.dart';
import 'package:admin/model/images.dart';
import 'package:admin/model/property.dart';
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

  int currentPageIndex = 0;

  late Future<List<PropertySchema>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    _propertiesFuture = BookingAppDB.instance.getAllProperties();
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

  Future<void> _deleteProperty(int propertyId) async {
    await BookingAppDB.instance.deleteProperty(propertyId);
    setState(() {
      _propertiesFuture = BookingAppDB.instance.getAllProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-property',
                    arguments: _user,
                  ).then((_) {
                    BookingAppDB.instance.getAllProperties().then((value) {
                    setState(() {
                      _propertiesFuture = Future.value(value);
                    });
                  });
                  });
                },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              BookingAppDB.instance.getAllProperties().then((value) {
                setState(() {
                  _propertiesFuture = Future.value(value);
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut().then((_) {
                Navigator.popAndPushNamed(context, '/login');
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Minhas propriedades",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<PropertySchema>>(
              future: _propertiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _user == null) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty || snapshot.data!.where((property) => property.userId == _user!.id).toList().isEmpty) {
                  return const Center(
                      child: Text('Nenhuma propriedade encontrada.'));
                } else {
                  final allProperties = snapshot.data!;
                  final properties = allProperties.where((property) => property.userId == _user!.id).toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return FutureBuilder<List<ImageSchema>>(
                        future: BookingAppDB.instance
                            .getImagesByProperty(property.id!),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (imageSnapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Erro ao carregar imagens: ${imageSnapshot.error}'));
                          } else {
                            final images = imageSnapshot.data ?? [];
                            return FutureBuilder<Address?>(
                              future: BookingAppDB.instance.getAddress(property.addressId),
                              builder: (context, addressSnapshot) {
                                if (addressSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (addressSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Erro ao carregar endereço: ${addressSnapshot.error}'));
                                } else if (!addressSnapshot.hasData) {
                                  return const Center(child: Text('Endereço não encontrado.'));
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
                                                String imagePath = images[pageIndex].path;
                                                File imageFile = File(imagePath);
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: imageFile.existsSync()
                                                        ? Image.file(
                                                      imageFile,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    )
                                                        : const Center(child: Text('Imagem não encontrada.')),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${address.localidade}, ${address.uf}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'R\$${property.price} noite',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/edit-property',
                                                        arguments: {
                                                          'property': property,
                                                          'user': _user,
                                                        },
                                                      ).then((_) {
                                                        BookingAppDB.instance.getAllProperties().then((value) {
                                                          setState(() {
                                                            _propertiesFuture = Future.value(value);
                                                          });
                                                        });
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () async {
                                                      bool confirmDelete = await showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Confirmar exclusão'),
                                                          content: const Text('Tem certeza que deseja excluir esta propriedade?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, false),
                                                              child: const Text('Cancelar'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, true),
                                                              child: const Text(
                                                                'Excluir',
                                                                style: TextStyle(color: Colors.red),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirmDelete == true) {
                                                        await _deleteProperty(property.id!);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
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
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthPreferences.removeAuthenticationInfo();
  }
}
