class ApiService {
  static const String baseUrl = 'https://api.example.com';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String refresh = '$baseUrl/auth/refresh';

  // Employee endpoints
  static const String employees = '$baseUrl/employees';
  static const String employeeById = '$baseUrl/employees/'; // + id
  static const String employeeRegistrations =
      '$baseUrl/employees/'; // + id/registrations

  // Restaurant endpoints
  static const String restaurants = '$baseUrl/restaurants';
  static const String restaurantById = '$baseUrl/restaurants/'; // + id
  static const String restaurantEmployees =
      '$baseUrl/restaurants/'; // + id/employees

  // Registration endpoints
  static const String registrations = '$baseUrl/registrations';
  static const String registrationById = '$baseUrl/registrations/'; // + id
  static const String approveRegistration =
      '$baseUrl/registrations/'; // + id/approve
  static const String rejectRegistration =
      '$baseUrl/registrations/'; // + id/reject

  // Statistics endpoints
  static const String yearlyStats = '$baseUrl/statistics/yearly';
  static const String monthlyStats = '$baseUrl/statistics/monthly';
  static const String weeklyStats = '$baseUrl/statistics/weekly';
}
