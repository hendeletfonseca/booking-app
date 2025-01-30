import 'package:admin/model/address.dart';
import 'package:flutter/material.dart';
import 'package:admin/service/api.dart' as api;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  _CreatePropertyState createState() => _CreatePropertyState();
}

class _CreatePropertyState extends State<CreatePropertyPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _maxGuestController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();

  Address? _address;

  Future<void> _buscarCep() async {
    api.getCep(_cepController.text).then((address) {
      if (address != null) {
        setState(() {
          _address = address;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP não encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Widget _buildAddressInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
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

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
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

  void _criarPropriedade() {
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

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A imagem do thumbnail é obrigatória'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Propriedade criada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Propriedade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite o CEP:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _buscarCep,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_address != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressInfo('Logradouro', _address!.logradouro),
                      _buildAddressInfo('Bairro', _address!.bairro),
                      _buildAddressInfo('Cidade', _address!.localidade),
                      _buildAddressInfo('Estado', _address!.uf),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Título", _titleController),
              _buildTextField("Descrição", _descriptionController),
              _buildTextField("Número", _numberController,
                  keyboardType: TextInputType.number),
              _buildTextField("Complemento", _complementController),
              _buildTextField("Preço", _priceController,
                  keyboardType: TextInputType.number),
              _buildTextField("Máx. Hóspedes", _maxGuestController,
                  keyboardType: TextInputType.number),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Selecionar Imagem (Thumbnail)"),
                ),
              ),
              if (_image != null) ...[
                const SizedBox(height: 8),
                Text("Imagem Selecionada: ${_image!.path}"),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _criarPropriedade,
                  child: const Text("Criar Propriedade"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
