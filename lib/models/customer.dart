class Customer {
  final int? id;
  final String nama;
  final String noPelanggan;
  final String noTelepon;
  final String email;
  final String alamat;
  final String golongan;
  final String zona;
  final bool isAktif;

  Customer({
    this.id,
    required this.nama,
    required this.noPelanggan,
    required this.noTelepon,
    required this.email,
    required this.alamat,
    required this.golongan,
    required this.zona,
    this.isAktif = true,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Mapping dari backend UKL PDAM ke field UI
    final service = json['service'] as Map<String, dynamic>?;
    return Customer(
      id: json['id'] as int?,
      nama: json['name']?.toString() ?? json['nama']?.toString() ?? '',
      noPelanggan: json['customer_number']?.toString() ??
          json['noPelanggan']?.toString() ??
          '',
      noTelepon: json['phone']?.toString() ??
          json['noTelepon']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      alamat: json['address']?.toString() ??
          json['alamat']?.toString() ??
          '',
      golongan: service?['name']?.toString() ??
          json['golongan']?.toString() ??
          'R1',
      zona: json['zona']?.toString() ?? 'Zona A',
      isAktif: json['isAktif'] == true || json['isAktif'] == null,
    );
  }

  get isActive => null;

  get customerNumber => null;

  get address => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nama,
      'customer_number': noPelanggan,
      'phone': noTelepon,
      'email': email,
      'address': alamat,
      'golongan': golongan,
      'zona': zona,
      'isAktif': isAktif,
    };
  }
}