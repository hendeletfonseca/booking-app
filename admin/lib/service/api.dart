import 'dart:convert';
import 'package:admin/model/address.dart';
import 'package:http/http.dart' as http;

Future<Address?> getCep(String cep) async {
  String url = "https://viacep.com.br/ws/$cep/json/";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
