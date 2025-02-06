import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/time_registration.dart';
import '../models/role.dart';
import '../models/permission.dart' as perm;
import '../models/restaurant.dart';
import '../models/period_type.dart';

class TimeRegistrationProvider extends ChangeNotifier {
  final List<TimeRegistration> _registrations = [];
  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'Jeffrey van Prehn',
      function: 'Super Admin',
      role: Role.superAdmin,
    ),
    Employee(
      id: '2',
      name: 'Cemil Sahinturk',
      function: 'Eigenaar',
      role: Role.owner,
      restaurantId: 'rest_1',
    ),
    Employee(
      id: '3',
      name: 'Jan Janssen',
      function: 'Manager',
      role: Role.manager,
      restaurantId: 'rest_1',
    ),
    Employee(
      id: '4',
      name: 'Piet Peters',
      function: 'Medewerker',
      role: Role.employee,
      restaurantId: 'rest_1',
    ),
    Employee(
      id: '5',
      name: 'Test Eigenaar',
      function: 'Eigenaar',
      role: Role.owner,
      restaurantId: 'rest_2',
    ),
    Employee(
      id: '6',
      name: 'Test Manager',
      function: 'Manager',
      role: Role.manager,
      restaurantId: 'rest_2',
    ),
    Employee(
      id: '7',
      name: 'Test Medewerker',
      function: 'Medewerker',
      role: Role.employee,
      restaurantId: 'rest_2',
    ),
  ];

  // Huidige ingelogde gebruiker (later via auth)
  Employee? _currentEmployee;
  Employee? get currentEmployee => _currentEmployee;

  // Constructor om initiële gebruiker in te stellen (later via auth)
  TimeRegistrationProvider() {
    _currentEmployee = _employees.first; // Start als superAdmin voor testing

    // Voeg test registraties toe
    _registrations.addAll([
      TimeRegistration(
        employeeId: '4', // Piet Peters
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        status: RegistrationStatus.pending,
      ),
      TimeRegistration(
        employeeId: '3', // Jan Janssen
        date: DateTime.now().subtract(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 16, minute: 30),
        status: RegistrationStatus.approved,
      ),
      // Voeg meer test data toe...
    ]);
  }

  // Check permissions voor huidige gebruiker
  bool hasPermission(perm.Permission permission) {
    return _currentEmployee?.hasPermission(permission) ?? false;
  }

  // Gefilterde lijst van medewerkers gebaseerd op rechten
  List<Employee> getVisibleEmployees() {
    if (_currentEmployee == null) return [];

    // Superadmin ziet alle medewerkers
    if (_currentEmployee!.hasPermission(perm.Permission.viewAllRestaurants)) {
      return _employees;
    }

    // Als de medewerker aan een restaurant is gekoppeld, toon alle medewerkers van dat restaurant
    if (_currentEmployee!.restaurantId != null) {
      return _employees
          .where((emp) => emp.restaurantId == _currentEmployee!.restaurantId)
          .toList();
    }

    // Fallback: alleen eigen gegevens als er geen restaurant is gekoppeld
    return [_currentEmployee!];
  }

  // Helper methode om te bepalen of een medewerker bewerkbaar is
  bool canEditEmployee(String employeeId) {
    if (_currentEmployee == null) return false;

    // Superadmin kan alles bewerken, inclusief restaurant verplaatsingen
    if (_currentEmployee!.role == Role.superAdmin) {
      return true;
    }

    // Eigenaar en manager kunnen alleen medewerkers in eigen restaurant bewerken
    if (_currentEmployee!.hasPermission(perm.Permission.manageEmployees)) {
      final employee = _employees.firstWhere((e) => e.id == employeeId);
      final targetRestaurantId = employee.restaurantId;

      // Voorkom dat niet-superadmins medewerkers naar ander restaurant kunnen verplaatsen
      if (targetRestaurantId != null &&
          targetRestaurantId != _currentEmployee!.restaurantId) {
        return false;
      }

      return employee.restaurantId == _currentEmployee!.restaurantId;
    }

    // Eigen gegevens bewerken
    if (_currentEmployee!.hasPermission(perm.Permission.editOwnData)) {
      return employeeId == _currentEmployee!.id;
    }

    return false;
  }

  List<TimeRegistration> get registrations => _registrations;
  List<Employee> get employees => _employees;

  final List<Restaurant> _restaurants = [
    Restaurant(
      id: 'rest_1',
      name: 'Restaurant Cemil',
      employees: ['2', '3', '4'], // Cemil restaurant medewerkers
    ),
    Restaurant(
      id: 'rest_2',
      name: 'Restaurant Test',
      employees: ['5', '6', '7'], // Test restaurant medewerkers
    ),
  ];

  // Gefilterde lijst van restaurants gebaseerd op rechten
  List<Restaurant> getVisibleRestaurants() {
    if (_currentEmployee == null) return [];

    // Superadmin ziet alle restaurants
    if (_currentEmployee!.hasPermission(perm.Permission.viewAllRestaurants)) {
      return _restaurants;
    }

    // Andere gebruikers zien alleen hun eigen restaurant
    if (_currentEmployee!.restaurantId != null) {
      return _restaurants
          .where((rest) => rest.id == _currentEmployee!.restaurantId)
          .toList();
    }

    return [];
  }

  // Update de restaurants getter om de filter toe te passen
  List<Restaurant> get restaurants =>
      List.unmodifiable(getVisibleRestaurants());

  // Medewerker toevoegen
  void addEmployee(String name, String function, Role role,
      {String? restaurantId}) {
    final employee = Employee(
      id: 'emp_${_employees.length + 1}',
      name: name,
      function: function,
      role: role,
      restaurantId: restaurantId,
    );
    _employees.add(employee);

    // Update ook de restaurant-employee relatie
    if (restaurantId != null) {
      final restaurant = _restaurants.firstWhere((r) => r.id == restaurantId);
      restaurant.employees.add(employee.id);
    }

    notifyListeners();
  }

  // Medewerker bewerken
  void updateEmployee(String id, String name, String function, Role role,
      {String? restaurantId}) {
    final index = _employees.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final oldEmployee = _employees[index];

    // Check of de huidige gebruiker deze wijziging mag maken
    if (!canEditEmployee(id)) return;

    // Voor niet-superadmins: voorkom wijzigen van restaurant
    if (_currentEmployee?.role != Role.superAdmin &&
        restaurantId != oldEmployee.restaurantId) {
      return;
    }

    // Verwijder employee van oude restaurant als die er was
    if (oldEmployee.restaurantId != null) {
      final oldRestaurant =
          _restaurants.firstWhere((r) => r.id == oldEmployee.restaurantId);
      oldRestaurant.employees.remove(oldEmployee.id);
    }

    // Maak nieuwe employee instantie
    final updatedEmployee = Employee(
      id: id,
      name: name,
      function: function,
      role: role,
      restaurantId: restaurantId,
    );

    // Update employee in lijst
    _employees[index] = updatedEmployee;

    // Voeg employee toe aan nieuwe restaurant
    if (restaurantId != null) {
      final newRestaurant =
          _restaurants.firstWhere((r) => r.id == restaurantId);
      newRestaurant.employees.add(updatedEmployee.id);
    }

    notifyListeners();
  }

  // Medewerker verwijderen
  void deleteEmployee(String id) {
    final employee = _employees.firstWhere((e) => e.id == id);

    // Verwijder employee van restaurant als die er was
    if (employee.restaurantId != null) {
      final restaurant =
          _restaurants.firstWhere((r) => r.id == employee.restaurantId);
      restaurant.employees.remove(employee.id);
    }

    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Helper methode om te bepalen of een tijdregistratie bewerkt mag worden
  bool canEditRegistration(String employeeId, TimeRegistration? registration) {
    if (_currentEmployee == null) return false;

    // Superadmin, owner en manager mogen alle tijden aanpassen
    if (_currentEmployee!.role == Role.superAdmin ||
        _currentEmployee!.role == Role.owner ||
        _currentEmployee!.role == Role.manager) {
      // Check of de medewerker in hetzelfde restaurant zit (behalve voor superadmin)
      if (_currentEmployee!.role != Role.superAdmin) {
        final employee = _employees.firstWhere((e) => e.id == employeeId);
        if (employee.restaurantId != _currentEmployee!.restaurantId) {
          return false;
        }
      }
      return true;
    }

    // Medewerkers mogen alleen hun eigen pending registraties aanpassen
    return employeeId == _currentEmployee!.id &&
        (registration == null ||
            registration.status == RegistrationStatus.pending);
  }

  // Update de bestaande registratie methodes om rechtencontrole toe te voegen
  void addRegistration(TimeRegistration registration) {
    if (!canEditRegistration(registration.employeeId, null)) return;

    _registrations.add(registration);
    notifyListeners();
  }

  void updateRegistration(TimeRegistration registration) {
    if (!canEditRegistration(registration.employeeId, registration)) return;

    final index = _registrations.indexWhere((reg) =>
        reg.employeeId == registration.employeeId &&
        reg.date.year == registration.date.year &&
        reg.date.month == registration.date.month &&
        reg.date.day == registration.date.day);

    if (index != -1) {
      _registrations[index] = registration;
      notifyListeners();
    }
  }

  void addRestaurant(String name) {
    final newRestaurant = Restaurant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      employees: [],
    );
    _restaurants.add(newRestaurant);
    notifyListeners();
  }

  void updateRestaurant(Restaurant updatedRestaurant) {
    final index = _restaurants.indexWhere((r) => r.id == updatedRestaurant.id);
    if (index != -1) {
      _restaurants[index] = updatedRestaurant;
      notifyListeners();
    }
  }

  void deleteRestaurant(String id) {
    _restaurants.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void assignEmployeeToRestaurant(String employeeId, String restaurantId) {
    // Update employee
    final employeeIndex = _employees.indexWhere((e) => e.id == employeeId);
    if (employeeIndex != -1) {
      _employees[employeeIndex] = _employees[employeeIndex].copyWith(
        restaurantId: restaurantId,
      );
    }

    // Update restaurant
    final restaurantIndex =
        _restaurants.indexWhere((r) => r.id == restaurantId);
    if (restaurantIndex != -1) {
      final updatedEmployees =
          List<String>.from(_restaurants[restaurantIndex].employees);
      if (!updatedEmployees.contains(employeeId)) {
        updatedEmployees.add(employeeId);
        _restaurants[restaurantIndex] = _restaurants[restaurantIndex].copyWith(
          employees: updatedEmployees,
        );
      }
    }
    notifyListeners();
  }

  void toggleRestaurantStatus(String restaurantId) {
    final index = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      _restaurants[index] = _restaurants[index].copyWith(
        isActive: !_restaurants[index].isActive,
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  List<Employee> getEmployeesByRestaurant(String? restaurantId) {
    if (restaurantId == null) return _employees;
    return _employees.where((emp) => emp.restaurantId == restaurantId).toList();
  }

  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update huidige gebruiker
  void setCurrentEmployee(Employee employee) {
    _currentEmployee = employee;
    notifyListeners();
  }

  // Logout functie
  void logout() {
    _currentEmployee = null;
    notifyListeners();
  }

  // Check login status
  bool get isLoggedIn => _currentEmployee != null;

  // Login verificatie
  bool verifyCredentials(String email, String password) {
    // Super admin credentials
    if (email == 'laventejeffrey@gmail.com' && password == 'Bootje@12') {
      final superAdmin = _employees.firstWhere(
        (emp) => emp.role == Role.superAdmin,
      );
      setCurrentEmployee(superAdmin);
      return true;
    }

    // Test accounts voor verschillende rollen
    final testAccounts = {
      // Restaurant Cemil accounts
      'owner@urcs.nl': ('owner123', '2'), // Cemil (Owner)
      'manager@urcs.nl': ('manager123', '3'), // Jan (Manager)
      'employee@urcs.nl': ('employee123', '4'), // Piet (Employee)

      // Restaurant Test accounts
      'test.owner@urcs.nl': ('owner123', '5'), // Test Owner
      'test.manager@urcs.nl': ('manager123', '6'), // Test Manager
      'test.employee@urcs.nl': ('employee123', '7'), // Test Employee
    };

    if (testAccounts.containsKey(email)) {
      final (expectedPassword, employeeId) = testAccounts[email]!;
      if (password == expectedPassword) {
        final employee = _employees.firstWhere(
          (emp) => emp.id == employeeId,
        );
        setCurrentEmployee(employee);
        return true;
      }
    }

    return false;
  }

  // Voeg deze methode toe aan de TimeRegistrationProvider class
  void updateRegistrationStatus(
    TimeRegistration registration,
    RegistrationStatus status, {
    String? note,
    String? approvedById,
  }) {
    final index = _registrations.indexWhere((reg) =>
        reg.employeeId == registration.employeeId &&
        reg.date.year == registration.date.year &&
        reg.date.month == registration.date.month &&
        reg.date.day == registration.date.day);

    if (index != -1) {
      _registrations[index] = registration.copyWith(
        status: status,
        note: note,
        approvedById: approvedById,
        statusDate: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Periode selectie
  PeriodType _selectedPeriodType = PeriodType.year;
  int _selectedYear = DateTime.now().year;
  int? _selectedWeek;
  int? _selectedMonth;

  // Getters
  PeriodType get selectedPeriodType => _selectedPeriodType;
  int get selectedYear => _selectedYear;
  int? get selectedWeek => _selectedWeek;
  int? get selectedMonth => _selectedMonth;

  // Setters
  void updatePeriod({
    PeriodType? periodType,
    int? year,
    int? week,
    int? month,
  }) {
    if (periodType != null) _selectedPeriodType = periodType;
    if (year != null) _selectedYear = year;
    _selectedWeek = week;
    _selectedMonth = month;
    notifyListeners();
  }

  // Voeg deze methode toe
  Employee? getEmployeeById(String id) {
    try {
      return employees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }
}
