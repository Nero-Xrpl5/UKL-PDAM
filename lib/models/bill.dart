class Bill {
  final int? id;
  final int? customerId;
  final String? customerName;
  final String? customerNumber;
  final int? serviceId;
  final int? month;
  final int? year;
  final String? measurementNumber;
  final int? usageValue;
  final int? totalBill;
  final String? status;
  final String? dueDate;
  final String? createdAt;

  Bill({
    this.id,
    this.customerId,
    this.customerName,
    this.customerNumber,
    this.serviceId,
    this.month,
    this.year,
    this.measurementNumber,
    this.usageValue,
    this.totalBill,
    this.status,
    this.dueDate,
    this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? json['customer']?['name'],
      customerNumber: json['customer_number'] ?? json['customer']?['customer_number'],
      serviceId: json['service_id'],
      month: json['month'],
      year: json['year'],
      measurementNumber: json['measurement_number'],
      usageValue: json['usage_value'],
      totalBill: json['total_bill'] ?? json['total'],
      status: json['status'] ?? 'unpaid',
      dueDate: json['due_date'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'month': month,
      'year': year,
      'measurement_number': measurementNumber,
      'usage_value': usageValue,
      'status': status,
      'due_date': dueDate,
    };
  }
}
