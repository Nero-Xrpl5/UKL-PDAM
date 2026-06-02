class Service {
  final int? id;
  final String? name;
  final String? description;
  final int? minUsage;
  final int? maxUsage;
  final int? price;
  final String? category;
  final bool? isActive;
  final String? createdAt;

  Service({
    this.id,
    this.name,
    this.description,
    this.minUsage,
    this.maxUsage,
    this.price,
    this.category,
    this.isActive,
    this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      minUsage: json['min_usage'],
      maxUsage: json['max_usage'],
      price: json['price'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'min_usage': minUsage,
      'max_usage': maxUsage,
      'price': price,
      'category': category,
      'is_active': isActive,
    };
  }
}
