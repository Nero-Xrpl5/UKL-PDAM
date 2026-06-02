class Customer {
  final int? id;
  final String? username;
  final String? name;
  final String? email;
  final String? phone;
  final String? customerNumber;
  final String? address;
  final int? serviceId;
  final String? golongan;
  final String? zona;
  final bool? isActive;
  final String? createdAt;

  Customer({
    this.id,
    this.username,
    this.name,
    this.email,
    this.phone,
    this.customerNumber,
    this.address,
    this.serviceId,
    this.golongan,
    this.zona,
    this.isActive,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      customerNumber: json['customer_number'],
      address: json['address'],
      serviceId: json['service_id'],
      golongan: json['golongan'],
      zona: json['zona'],
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
      'customer_number': customerNumber,
      'address': address,
      'service_id': serviceId,
      'golongan': golongan,
      'zona': zona,
      'is_active': isActive,
    };
  }
}
