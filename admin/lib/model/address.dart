class Address {
  final int? id;
  final String cep;
  final String logradouro;
  final String bairro;  
  final String localidade;
  final String uf;
  final String estado;

  Address({
    this.id,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'estado': estado,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      cep: json['cep'],
      logradouro: json['logradouro'],
      bairro: json['bairro'],
      localidade: json['localidade'],
      uf: json['uf'],
      estado: json['estado'],
    );
  }

  Address copy({
    int? id,
    String? cep,
    String? logradouro,
    String? bairro,
    String? localidade,
    String? uf,
    String? estado,
  }) {
    return Address(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      bairro: bairro ?? this.bairro,
      localidade: localidade ?? this.localidade,
      uf: uf ?? this.uf,
      estado: estado ?? this.estado,
    );
  }

  @override
  String toString() {
    return 'Address{id: $id, cep: $cep, logradouro: $logradouro, bairro: $bairro, localidade: $localidade, uf: $uf, estado: $estado}';
  }

}