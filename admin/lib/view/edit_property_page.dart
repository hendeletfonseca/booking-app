import 'package:admin/database/db.dart';
import 'package:admin/model/address.dart';
import 'package:admin/model/property.dart';
import 'package:admin/model/user.dart';
import 'package:flutter/material.dart';
import 'package:admin/service/api.dart' as api;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';

class EditPropertyPage extends StatefulWidget {
  const EditPropertyPage({super.key});

  @override
  _EditPropertyState createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditPropertyPage> {
  PropertySchema? _property;
  UserSchema? _user;

  final ImagePicker _picker = ImagePicker();
  File? _imageThumbnail;
  List<File> _images = [];

  bool _isSearchingCep = false;
  bool _isCreatingProperty = false;

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _maxGuestController = TextEditingController();

  Address? _address;

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {
        _property = args['property'] as PropertySchema?;
        _user = args['user'] as UserSchema?;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_property != null && _firstLoad) {
      setState(() {
        _firstLoad = false;
      });
      BookingAppDB db = BookingAppDB.instance;
      db.getAddress(_property!.addressId).then((address) {
        setState(() {
          _titleController.text = _property!.title;
          _descriptionController.text = _property!.description;
          _numberController.text = _property!.number.toString();
          _complementController.text = _property!.complement ?? '';
          _priceController.text = _property!.price.toString();
          _maxGuestController.text = _property!.maxGuests.toString();
          _address = address;
          _cepController.text = address!.cep;
          _imageThumbnail = File(_property!.thumbnail);
        });
      });

      db.getImagesByProperty(_property!.id!).then((images) {
        setState(() {
          _images = images
              .where((image) => image.path != _property!.thumbnail)
              .map((image) => File(image.path))
              .toList();
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Propriedade'),
      ),
      body: _property == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Digite o CEP:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cepController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'CEP',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSearchingCep ? null : _buscarCep,
                        child: _isSearchingCep
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_address != null) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Logradouro: ${_address!.logradouro}'),
                            Text('Bairro: ${_address!.bairro}'),
                            Text('Cidade: ${_address!.localidade}'),
                            Text('Estado: ${_address!.uf}'),
                          ],
                        ),
                      ),
                    ),
                    _buildTextField("Título", _titleController),
                    _buildTextField("Descrição", _descriptionController),
                    _buildTextField("Número", _numberController,
                        keyboardType: TextInputType.number),
                    _buildTextField("Complemento", _complementController),
                    _buildTextField("Preço", _priceController,
                        keyboardType: TextInputType.number),
                    _buildTextField("Máx. Hóspedes", _maxGuestController,
                        keyboardType: TextInputType.number),
                    ElevatedButton(
                      onPressed: _pickThumbnail,
                      child: const Text("Selecionar Imagem (Thumbnail)"),
                    ),
                    if (_imageThumbnail != null)
                      Image.file(
                        File(_imageThumbnail!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Selecionar Imagens Adicionais"),
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Imagens Adicionais:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 120,
                          autoPlay: true,
                          enableInfiniteScroll: false,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.3,
                        ),
                        items: _images.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final image = entry.value;
                          return Builder(
                            builder: (BuildContext context) {
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(image.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreatingProperty ? null : null,
                        child: _isCreatingProperty
                            ? const CircularProgressIndicator()
                            : const Text("Salvar"),
                      ),
                    ),
                  ]
                ],
              ),
            ),
    );
  }

  Future<void> _buscarCep() async {
    setState(() {
      _isSearchingCep = true;
    });

    String cepFormated = _cepController.text.replaceFirstMapped(
        RegExp(r'^(\d{5})(\d{3})$'),
        (match) => '${match.group(1)}-${match.group(2)}');

    BookingAppDB db = BookingAppDB.instance;
    Address? dbAddress = await db.fetchAddressByCEP(cepFormated);

    if (dbAddress != null) {
      setState(() {
        _address = dbAddress;
        _isSearchingCep = false;
      });
      return;
    }

    api.getCep(cepFormated).then((address) {
      if (address != null) {
        db.insertAddress(address).then((onValue) {
          setState(() {
            _address = onValue;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP não encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isSearchingCep = false;
      });
    });
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = Directory('/storage/emulated/0/BookingApp/Images');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final File newImage = File('${directory.path}/${pickedFile.name}');
      await File(pickedFile.path).copy(newImage.path);

      setState(() {
        _imageThumbnail = newImage;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma imagem selecionada'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = Directory('/storage/emulated/0/BookingApp/Images');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final File newImage = File('${directory.path}/${pickedFile.name}');
      await File(pickedFile.path).copy(newImage.path);

      setState(() {
        _images.add(newImage);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma imagem selecionada'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showError(String message, TextEditingController controller) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _editarPropriedade() async {
    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, busque um endereço primeiro.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      _showError("O título é obrigatório", _titleController);
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showError("A descrição é obrigatória", _descriptionController);
      return;
    }

    if (_numberController.text.isEmpty ||
        int.tryParse(_numberController.text) == null) {
      _showError("Informe um número válido para o endereço", _numberController);
      return;
    }

    if (_priceController.text.isEmpty ||
        double.tryParse(_priceController.text) == null) {
      _showError("Informe um preço válido", _priceController);
      return;
    }

    if (_maxGuestController.text.isEmpty ||
        int.tryParse(_maxGuestController.text) == null) {
      _showError("Informe um número válido de hóspedes", _maxGuestController);
      return;
    }

    if (_imageThumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A imagem do thumbnail é obrigatória'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingProperty = true;
    });

    BookingAppDB db = BookingAppDB.instance;
    _address = await db.insertAddress(_address!);

    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar o endereço'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isCreatingProperty = false;
      });
      return;
    }

    PropertySchema property = PropertySchema(
      userId: _user!.id!,
      title: _titleController.text,
      description: _descriptionController.text,
      addressId: _address!.id!,
      number: int.parse(_numberController.text),
      complement: _complementController.text,
      price: double.parse(_priceController.text),
      maxGuests: int.parse(_maxGuestController.text),
      thumbnail: _imageThumbnail!.path,
    );

    final List<String> imagePaths = _images.map((image) => image.path).toList();

    property = await db.insertProperty(property, imagePaths);

    setState(() {
      _isCreatingProperty = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Propriedade Atualizada'),
          content: const Text('Sua propriedade foi atualizada com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
