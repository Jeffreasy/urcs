import 'role.dart';

enum Permission {
  // View permissions
  viewOwnData, // Eigen gegevens zien
  viewOwnRestaurant, // Medewerkers van eigen restaurant zien
  viewAllRestaurants, // Alle restaurants zien
  addRestaurant, // Restaurant toevoegen (alleen superadmin)
  manageOwners, // Eigenaren beheren
  manageManagers, // Managers beheren

  // Edit permissions
  editOwnData, // Eigen gegevens bewerken
  editOwnRestaurant, // Restaurant gegevens bewerken (verwijderd)
  editAllRestaurants, // Alle restaurants bewerken (alleen superadmin)

  // Admin permissions
  approveHours, // Uren goedkeuren
  manageEmployees, // Medewerkers beheren
  manageRestaurants, // Restaurants beheren (alleen superadmin)
}

extension PermissionExtension on Role {
  List<Permission> get permissions {
    switch (this) {
      case Role.superAdmin:
        return Permission.values;
      case Role.owner:
        return [
          Permission.viewOwnData,
          Permission.viewOwnRestaurant,
          Permission.editOwnData,
          Permission.approveHours,
          Permission.manageEmployees,
          Permission.manageManagers,
        ];
      case Role.manager:
        return [
          Permission.viewOwnData,
          Permission.viewOwnRestaurant,
          Permission.editOwnData,
          Permission.approveHours,
        ];
      case Role.employee:
        return [
          Permission.viewOwnData,
          Permission.viewOwnRestaurant,
          Permission.editOwnData,
        ];
    }
  }
}
