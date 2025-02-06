enum Role {
  superAdmin, // Jij - volledige systeem toegang
  owner, // Cemil - restaurant eigenaar
  manager, // Manager
  employee // Basis medewerker
}

class RolePermissions {
  static final Map<Role, Set<Permission>> permissions = {
    Role.superAdmin: {
      Permission.viewAllRestaurants,
      Permission.addRestaurant,
      Permission.editSystemSettings,
      Permission.viewAnalytics,
      Permission.manageOwners,
      Permission.viewOwnRestaurant,
      Permission.editRestaurantSettings,
      Permission.viewFinancials,
      Permission.manageManagers,
      Permission.manageEmployees,
      Permission.editSchedules,
      Permission.approveHours,
      Permission.viewReports,
      Permission.viewOwnSchedule,
      Permission.registerHours,
      Permission.viewOwnHours,
      Permission.editProfile,
    },
    Role.owner: {
      Permission.viewOwnRestaurant,
      Permission.editRestaurantSettings,
      Permission.viewFinancials,
      Permission.manageManagers,
      Permission.manageEmployees,
      Permission.editSchedules,
      Permission.approveHours,
      Permission.viewReports,
      Permission.viewOwnSchedule,
      Permission.registerHours,
      Permission.viewOwnHours,
      Permission.editProfile,
    },
    Role.manager: {
      Permission.manageEmployees,
      Permission.editSchedules,
      Permission.approveHours,
      Permission.viewReports,
      Permission.viewOwnSchedule,
      Permission.registerHours,
      Permission.viewOwnHours,
      Permission.editProfile,
    },
    Role.employee: {
      Permission.viewOwnSchedule,
      Permission.registerHours,
      Permission.viewOwnHours,
      Permission.editProfile,
    },
  };
}

enum Permission {
  // Super Admin specifiek
  viewAllRestaurants,
  addRestaurant,
  editSystemSettings,
  viewAnalytics,
  manageOwners,

  // Owner specifiek
  viewOwnRestaurant,
  editRestaurantSettings,
  viewFinancials,
  manageManagers,

  // Manager specifiek
  manageEmployees,
  editSchedules,
  approveHours,
  viewReports,

  // Medewerker basis rechten
  viewOwnSchedule,
  registerHours,
  viewOwnHours,
  editProfile,
}
