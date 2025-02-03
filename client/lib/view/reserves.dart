import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/user.dart';
import '../service/auth_preferences.dart';
import '../database/db.dart';
import 'package:booking_app/model/property.dart';
import '../model/address.dart';
import 'package:booking_app/model/booking.dart';

class Reserves extends StatefulWidget {
  const Reserves({super.key});

  @override
  State<Reserves> createState() => _ReservesState();
}

class _ReservesState extends State<Reserves> {
  UserSchema? _user; 
  PropertySchema? property;
  Future<AddressSchema?>? address;
  DateTimeRange? selectedDateRange;
  int selectedGuests = 1;
  double selectedRating = 0;
  List<BookingSchema> _bookings = [];
  bool _bookingConfirmed = false;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }

  }

  Future<void> _loadUserBookings(int userId) async {
    List<BookingSchema> bookings = await BookingAppDB.instance.getBookingsByUser(userId);
    setState(() {
      _bookings = bookings;
    });
  }

  Future<void> _confirmBooking() async {
    if (selectedDateRange == null || _user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecione as datas e faça login."), backgroundColor: Colors.red),
      );
      return;
    }
    
    String response = await BookingAppDB.instance.makeBooking(
      userId: _user!.id!,
      propertyId: property!.addressId,
      checkin: selectedDateRange!.start,
      checkout: selectedDateRange!.end,
      guests: selectedGuests,
      pricePerNight: property!.price, 
      rating: selectedRating,
    );
  
    if (response == "Reserva feita com sucesso!") {
      setState(() {
        _bookingConfirmed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Reserva confirmada!"),
          backgroundColor: Colors.green,
        ),
      );
      _loadUserBookings(_user!.id!);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response), backgroundColor: Colors.red,),
      );
    }
  }

  String _calculateTotal() {
    if (selectedDateRange == null || property == null) {
      return "Selecione as datas para calcular o total.";
    }

    int totalDays = selectedDateRange!.end.difference(selectedDateRange!.start).inDays;
    double totalPrice = totalDays * property!.price;

    return "Total de dias: $totalDays\nValor total: R\$ ${totalPrice.toStringAsFixed(2)}";
  }

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    _getUserData(); 
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

    if (args != null) {
      property = args['property'];
      final UserSchema? user = args['user'];
      if (user != null) {
        _user = user;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(property?.title ?? 'Reservas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selecione as datas:", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:  () => {
                _selectDateRange(context)
              },
              child: Text(selectedDateRange == null
                  ? "Escolher datas"
                  : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}"),
            ),
            const SizedBox(height: 20),
            Text("Número de hóspedes:", style: Theme.of(context).textTheme.titleLarge),
            DropdownButton<int>(
              value: selectedGuests,
              items: List.generate(30, (index) => index + 1)
                  .map((num) => DropdownMenuItem(value: num, child: Text("$num hóspedes")))
                  .toList(),
              onChanged: (value) => setState(() => selectedGuests = value!),
            ),
            const SizedBox(height: 20),
            Text("Avaliação:", style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => selectedRating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 30),
            
            Text(
              _calculateTotal(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green, 
                  ),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text("Confirmar Reserva"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
