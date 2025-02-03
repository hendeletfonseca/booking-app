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
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
    if (await Permission.manageExternalStorage.isGranted){
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

  void _showCalendarDialog(
      BuildContext context, Function(DateTime) onDateSelected) {
    DateTime _selectedDate = DateTime.now(); // Data inicial

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                onDateSelected(selectedDay);
                Navigator.pop(context);
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    DateTime? _dataCheckin;
    DateTime? _dataCheckout;
    String? _uf;
    String? _cidade;
    String? _bairro;
    int? _hospedes;

    final List<String> ufs = [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
      'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
      'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _uf,
                  decoration: InputDecoration(
                    labelText: 'Selecione o Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: ufs.map((String uf) {
                    return DropdownMenuItem<String>(
                      value: uf,
                      child: Text(uf),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _uf = value; // Atualiza a UF selecionada
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Para qual cidade deseja ir?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cidade = value; // Atualiza a cidade
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Bairro',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _bairro = value; // Atualiza o bairro
                    });
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Abre o calendário quando o campo é tocado
                    _showCalendarDialog(context, (selectedDate) {
                      setState(() {
                        _dataCheckin =
                            selectedDate;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _dataCheckin != null
                            ? '${_dataCheckin!.day}/${_dataCheckin!.month}/${_dataCheckin!.year}'
                            : 'Data de check-in',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Abre o calendário quando o campo é tocado
                    _showCalendarDialog(context, (selectedDate) {
                      setState(() {
                        _dataCheckout =
                            selectedDate; // Atualiza a data de check-out
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _dataCheckout != null
                            ? '${_dataCheckout!.day}/${_dataCheckout!.month}/${_dataCheckout!.year}' // Exibe a data de check-out
                            : 'Data de check-out',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Número de hóspedes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hospedes =
                          int.tryParse(value); // Atualiza o número de hóspedes
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _propertiesFuture =
                          BookingAppDB.instance.getFilteredProperties(
                        uf: _uf,
                        cidade: _cidade,
                        bairro: _bairro,
                        checkin: _dataCheckin,
                        checkout: _dataCheckout,
                        hospedes: _hospedes,
                      );
                    });
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 50.0),
          // Ajuste o valor conforme necessário
          child: Image.asset(
            'assets/images/booking-texto.png',
            width: 150,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/booking-clients-logo.png',
                    width: 250,
                    height: 130,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bedroom_parent_outlined),
              title: const Text('Minhas Reservas'),
              onTap: () {
                Navigator.popAndPushNamed(context, '/my-bookings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Deslogar'),
              onTap: () {
                _signOut().then((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              },
            ),
          ],
        ),
      ),
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
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/book-page',  
                      arguments: {
                      'property': property,
                      'user': _user,
                    },); //tela de reservar
                  },
                  child: FutureBuilder<List<ImageSchema>>(
                    future:
                        BookingAppDB.instance.getImagesByProperty(property.id!),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (imageSnapshot.hasError) {
                        return Text(
                            'Erro ao carregar imagens: ${imageSnapshot.error}');
                      } else {
                        final images = imageSnapshot.data ?? [];
                        return FutureBuilder<AddressSchema?>(
                          future: BookingAppDB.instance
                              .getAddress(property.addressId),
                          builder: (context, addressSnapshot) {
                            if (addressSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (addressSnapshot.hasError) {
                              return Text(
                                  'Erro ao carregar endereço: ${addressSnapshot.error}');
                            } else if (!addressSnapshot.hasData) {
                              return const Text('Endereço não encontrado.');
                            } else {
                              final address = addressSnapshot.data!;
                              return Card(
                                elevation: 4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Carrossel de imagens
                                      SizedBox(
                                        height: 180,
                                        child: PageView.builder(
                                          itemCount: images.length,
                                          controller: PageController(
                                              viewportFraction: 0.8),
                                          itemBuilder: (context, pageIndex) {
                                            String imagePath =
                                                images[pageIndex].path;
                                            File imageFile = File(imagePath);
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: imageFile.existsSync()
                                                    ? Image.file(
                                                        imageFile,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Center(
                                                        child: Text(
                                                            'Imagem não encontrada.')),
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

                                      // Preço da noite
                                      Text(
                                        'R\$${property.price} noite',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      FutureBuilder<double>(
                                        future: BookingAppDB.instance
                                            .getAverageRatingForProperty(
                                                property.id!),
                                        builder: (context, ratingSnapshot) {
                                          if (ratingSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text(
                                              'Carregando avaliação...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            );
                                          } else if (ratingSnapshot.hasError) {
                                            return const Text(
                                              'Erro ao carregar avaliação',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            );
                                          } else if (!ratingSnapshot.hasData ||
                                              ratingSnapshot.data == 0) {
                                            return const Text(
                                              'Sem avaliações',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            );
                                          } else {
                                            final averageRating =
                                                ratingSnapshot.data!;
                                            return Text(
                                              '★ ${averageRating.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }
                                        },
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
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.9, // largura da tela
        child: FloatingActionButton.extended(
          onPressed: () {
            _showSearchBottomSheet(context);
          },
          icon: Icon(Icons.search),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explore novas experiências!',
                  style: TextStyle(fontSize: 16)),
              Text('A qualquer lugar • A qualquer hora',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          backgroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _signOut() async {
    await AuthPreferences.removeAuthenticationInfo();
  }
}
