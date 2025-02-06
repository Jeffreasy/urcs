class Restaurant {
  final String id;
  final String name;
  final List<String> employees; // List of employee IDs
  final String address;
  final String phoneNumber;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastModified;

  Restaurant({
    required this.id,
    required this.name,
    required this.employees,
    this.address = '',
    this.phoneNumber = '',
    this.email = '',
    this.isActive = true,
    DateTime? createdAt,
    this.lastModified,
  }) : createdAt = createdAt ?? DateTime.now();

  Restaurant copyWith({
    String? id,
    String? name,
    List<String>? employees,
    String? address,
    String? phoneNumber,
    String? email,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      employees: employees ?? this.employees,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
}
