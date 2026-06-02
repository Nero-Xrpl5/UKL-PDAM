class User {
  final int? id;
  final String? username;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? token;
  final bool? isActive;
  final String? createdAt;

  User({
    this.id,
    this.username,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.token,
    this.isActive,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'CUSTOMER',
      token: json['token'],
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
      'is_active': isActive,
      'createdAt': createdAt,
    };
  }
}