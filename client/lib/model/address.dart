class AddressSchema {
  final int? id;
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;
  final String estado;

  AddressSchema({
    this.id,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.estado,
  });

  // Converte o objeto AddressSchema para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'estado': estado,
    };
  }

  // Cria um objeto AddressSchema a partir de um Map (JSON)
  factory AddressSchema.fromJson(Map<String, dynamic> json) {
    return AddressSchema(
      id: json['id'],
      cep: json['cep'],
      logradouro: json['logradouro'],
      bairro: json['bairro'],
      localidade: json['localidade'],
      uf: json['uf'],
      estado: json['estado'],
    );
  }

  // Cria uma cópia do objeto AddressSchema com novos valores
  AddressSchema copy({
    int? id,
    String? cep,
    String? logradouro,
    String? bairro,
    String? localidade,
    String? uf,
    String? estado,
  }) {
    return AddressSchema(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      bairro: bairro ?? this.bairro,
      localidade: localidade ?? this.localidade,
      uf: uf ?? this.uf,
      estado: estado ?? this.estado,
    );
  }
}