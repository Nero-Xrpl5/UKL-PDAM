class ServiceRequest {
  final String id;
  final String customerName;
  final String customerNumber;
  final String serviceName;
  final String serviceType;
  final int price;
  final String status;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.customerName,
    required this.customerNumber,
    required this.serviceName,
    required this.serviceType,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerNumber': customerNumber,
      'serviceName': serviceName,
      'serviceType': serviceType,
      'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerNumber: json['customerNumber']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? '',
      price: (json['price'] ?? 0) as int,
      status: json['status']?.toString() ?? 'Baru',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}