class UserSchema {
  final int? id;
  final String username;
  final String email;
  final String password;

  UserSchema({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': username,
      'email': email,
      'password': password,
    };
  }


  factory UserSchema.fromJson(Map<String, dynamic> json) {
    return UserSchema(
      id: json['id'],
      username: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }

  UserSchema copy({
    int? id,
    String? username,
    String? email,
    String? password,
  }) {
    return UserSchema(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'UserSchema{id: $id, username: $username, email: $email, password: $password}';
  }
}