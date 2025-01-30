import 'package:admin/model/address.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:admin/service/api.dart' as api;

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  _CreatePropertyState createState() => _CreatePropertyState();
}

class _CreatePropertyState extends State<CreatePropertyPage> {
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
              _buildTextField("Thumbnail (URL)", _thumbnailController),
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
