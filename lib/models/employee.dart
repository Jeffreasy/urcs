import 'role.dart';
import 'permission.dart' as perm;

class Employee {
  final String id;
  final String name;
  final String function;
  final Role role;
  final String? restaurantId; // Null voor superAdmin
  final bool isActive; // Voeg isActive toe
  final bool isHeader; // Nieuwe property

  const Employee({
    required this.id,
    required this.name,
    required this.function,
    required this.role,
    this.restaurantId,
    this.isActive = true, // Standaard actief
    this.isHeader = false, // Default waarde
  });

  // Voeg copyWith methode toe
  Employee copyWith({
    String? id,
    String? name,
    String? function,
    Role? role,
    String? restaurantId,
    bool? isActive,
    bool? isHeader,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      function: function ?? this.function,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      isActive: isActive ?? this.isActive,
      isHeader: isHeader ?? this.isHeader,
    );
  }

  bool hasPermission(perm.Permission permission) {
    final permissions = RolePermissions.permissions[role];
    if (permissions == null) return false;
    return permissions.any((p) => p.toString() == permission.toString());
  }
}
