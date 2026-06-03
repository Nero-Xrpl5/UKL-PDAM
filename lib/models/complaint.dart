class Complaint {
  final String id;
  final String serviceName;
  final String description;
  final String category;
  final bool isActive;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.category,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'description': description,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Pemeliharaan',
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Complaint copyWith({
    String? id,
    String? serviceName,
    String? description,
    String? category,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}