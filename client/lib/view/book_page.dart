import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/user.dart';
import '../service/auth_preferences.dart';
import '../database/db.dart';
import 'dart:io';
import '../model/images.dart';
import 'full_screen.dart';
import 'package:booking_app/model/property.dart';
import '../model/address.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  UserSchema? _user;
  String welcomeText = 'Welcome to the home page';
  Future<List<ImageSchema>>? _imagesFuture;
  PropertySchema? property;
  Future<AddressSchema?>? address;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
      super.initState();
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

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    PropertySchema? property = args?['property'];
    final UserSchema? user = args?['user'];


    if (args != null) {
      setState(() {
        property = args['property'];
        _imagesFuture = BookingAppDB.instance.getImagesByProperty(property!.id!);
        address = BookingAppDB.instance.getAddress(property!.addressId);
      });
    }

    return Scaffold(
    appBar: AppBar(
      title: Text(property!.title),
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder <List<ImageSchema>>(
                  future: _imagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Erro ao carregar imagens: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("Nenhuma imagem disponível");
                    } else {
                      final images = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: PageView.builder(
                              itemCount: images.length,
                              controller: PageController(viewportFraction: 0.9),
                              itemBuilder: (context, index) {
                                String imagePath = images[index].path;
                                File imageFile = File(imagePath);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(imagePath: imagePath),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: imageFile.existsSync()
                                        ? Image.file(imageFile, fit: BoxFit.cover, width: double.infinity)
                                        : const Text('Imagem não encontrada'),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        property!.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property!.description,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "R\$ ${property!.price.toStringAsFixed(2)} por noite",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.group, color: Colors.green),
                            const SizedBox(width: 8),
                            Text("Máximo de ${property!.maxGuest} hóspedes"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 8),
                          Expanded(
                            child: FutureBuilder<AddressSchema?>(
                              future: address, 
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text("Carregando endereço...");
                                } else if (snapshot.hasError) {
                                  return Text("Erro ao carregar endereço: ${snapshot.error}");
                                } else if (!snapshot.hasData || snapshot.data == null) {
                                  return const Text("Endereço não disponível");
                                } else {
                                  final addressData = snapshot.data!;
                                  return Text(
                                    "${addressData.logradouro}, ${property!.number}, ${property!.complement} | ${addressData.bairro}, ${addressData.localidade} - ${addressData.uf}, ${addressData.cep}",
                                    overflow: TextOverflow.visible,
                                    softWrap: true
                                  );
                                }
                              },
                            ),
                          ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reserves', arguments: {
                            'property': property,
                            'user': user,
                          });
                        },
                        child: const Text(
                          'Reservar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/home-page');
                        },
                        child: const Text(
                          'Voltar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _signOut().then((_) {
                            Navigator.popAndPushNamed(context, '/login');
                          });
                        },
                        child: const Text(
                          'Sair',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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