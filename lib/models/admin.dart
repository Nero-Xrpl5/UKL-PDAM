class Admin {
  final int? id;
  final String? username;
  final String? name;
  final String? email;
  final String? phone;
  final bool? isActive;
  final String? createdAt;

  Admin({
    this.id,
    this.username,
    this.name,
    this.email,
    this.phone,
    this.isActive,
    this.createdAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': isActive,
    };
  }
}
