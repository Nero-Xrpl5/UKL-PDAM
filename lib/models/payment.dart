class Payment {
  final int? id;
  final int? billId;
  final String? billNumber;
  final String? customerName;
  final int? amount;
  final String? method;
  final String? status;
  final String? proofImage;
  final String? note;
  final String? createdAt;
  final String? paidAt;

  Payment({
    this.id,
    this.billId,
    this.billNumber,
    this.customerName,
    this.amount,
    this.method,
    this.status,
    this.proofImage,
    this.note,
    this.createdAt,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      billId: json['bill_id'],
      billNumber: json['bill_number'] ?? json['bill']?['measurement_number'],
      customerName: json['customer_name'] ?? json['customer']?['name'],
      amount: json['amount'],
      method: json['method'] ?? 'Transfer Bank',
      status: json['status'] ?? 'pending',
      proofImage: json['proof_image'] ?? json['file'],
      note: json['note'] ?? json['catatan'],
      createdAt: json['created_at'],
      paidAt: json['paid_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_id': billId,
      'amount': amount,
      'method': method,
      'status': status,
      'note': note,
    };
  }
}
