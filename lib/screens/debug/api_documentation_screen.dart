import 'package:flutter/material.dart';

class ApiEndpoint {
  final String path;
  final String method;
  final String description;
  final Map<String, dynamic>? requestBody;
  final Map<String, dynamic>? responseBody;

  const ApiEndpoint({
    required this.path,
    required this.method,
    required this.description,
    this.requestBody,
    this.responseBody,
  });
}

class ApiDocumentationScreen extends StatelessWidget {
  static const List<ApiEndpoint> endpoints = [
    // Auth Endpoints
    ApiEndpoint(
      path: '/auth/login',
      method: 'POST',
      description: 'Authenticeer een gebruiker',
      requestBody: {
        'email': 'string',
        'password': 'string',
      },
      responseBody: {
        'token': 'string',
        'user': {
          'id': 'string',
          'name': 'string',
          'role': 'string',
        },
      },
    ),
    ApiEndpoint(
      path: '/auth/logout',
      method: 'POST',
      description: 'Log de huidige gebruiker uit',
      responseBody: {
        'message': 'Successfully logged out',
      },
    ),
    ApiEndpoint(
      path: '/auth/refresh',
      method: 'POST',
      description: 'Vernieuw de access token',
      requestBody: {
        'refresh_token': 'string',
      },
      responseBody: {
        'access_token': 'string',
      },
    ),

    // Employee Endpoints
    ApiEndpoint(
      path: '/employees',
      method: 'GET',
      description: 'Haal alle medewerkers op',
      responseBody: {
        'employees': [
          {
            'id': 'string',
            'name': 'string',
            'function': 'string',
            'role': 'string',
            'restaurantId': 'string?',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/employees/{id}',
      method: 'GET',
      description: 'Haal specifieke medewerker op',
      responseBody: {
        'id': 'string',
        'name': 'string',
        'function': 'string',
        'role': 'string',
        'restaurantId': 'string?',
      },
    ),
    ApiEndpoint(
      path: '/employees/{id}/registrations',
      method: 'GET',
      description: 'Haal tijdregistraties van medewerker op',
      responseBody: {
        'registrations': [
          {
            'id': 'string',
            'employeeId': 'string',
            'date': 'string (YYYY-MM-DD)',
            'startTime': 'string (HH:mm)',
            'endTime': 'string (HH:mm)',
            'status': 'string',
            'note': 'string?',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/employees',
      method: 'POST',
      description: 'Maak een nieuwe medewerker aan',
      requestBody: {
        'name': 'string',
        'function': 'string',
        'role': 'string',
        'restaurantId': 'string?',
      },
      responseBody: {
        'id': 'string',
        'name': 'string',
        'function': 'string',
        'role': 'string',
        'restaurantId': 'string?',
      },
    ),
    ApiEndpoint(
      path: '/employees/{id}',
      method: 'PUT',
      description: 'Update een medewerker',
      requestBody: {
        'name': 'string?',
        'function': 'string?',
        'role': 'string?',
        'restaurantId': 'string?',
      },
      responseBody: {
        'id': 'string',
        'name': 'string',
        'function': 'string',
        'role': 'string',
        'restaurantId': 'string?',
      },
    ),
    ApiEndpoint(
      path: '/employees/{id}',
      method: 'DELETE',
      description: 'Verwijder een medewerker',
      responseBody: {
        'message': 'Employee deleted successfully',
      },
    ),

    // Restaurant Endpoints
    ApiEndpoint(
      path: '/restaurants',
      method: 'GET',
      description: 'Haal alle restaurants op',
      responseBody: {
        'restaurants': [
          {
            'id': 'string',
            'name': 'string',
            'isActive': 'boolean',
            'employees': 'string[]',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/restaurants/{id}',
      method: 'GET',
      description: 'Haal specifiek restaurant op',
      responseBody: {
        'id': 'string',
        'name': 'string',
        'isActive': 'boolean',
        'employees': 'string[]',
      },
    ),
    ApiEndpoint(
      path: '/restaurants/{id}/employees',
      method: 'GET',
      description: 'Haal medewerkers van restaurant op',
      responseBody: {
        'employees': [
          {
            'id': 'string',
            'name': 'string',
            'function': 'string',
            'role': 'string',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/restaurants',
      method: 'POST',
      description: 'Maak een nieuw restaurant aan',
      requestBody: {
        'name': 'string',
        'isActive': 'boolean',
      },
      responseBody: {
        'id': 'string',
        'name': 'string',
        'isActive': 'boolean',
        'employees': 'string[]',
      },
    ),
    ApiEndpoint(
      path: '/restaurants/{id}',
      method: 'PUT',
      description: 'Update een restaurant',
      requestBody: {
        'name': 'string?',
        'isActive': 'boolean?',
      },
      responseBody: {
        'id': 'string',
        'name': 'string',
        'isActive': 'boolean',
        'employees': 'string[]',
      },
    ),
    ApiEndpoint(
      path: '/restaurants/{id}',
      method: 'DELETE',
      description: 'Verwijder een restaurant',
      responseBody: {
        'message': 'Restaurant deleted successfully',
      },
    ),

    // Registration Endpoints
    ApiEndpoint(
      path: '/registrations',
      method: 'GET',
      description: 'Haal alle tijdregistraties op',
      responseBody: {
        'registrations': [
          {
            'id': 'string',
            'employeeId': 'string',
            'date': 'string (YYYY-MM-DD)',
            'startTime': 'string (HH:mm)',
            'endTime': 'string (HH:mm)',
            'status': 'string',
            'note': 'string?',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/registrations',
      method: 'POST',
      description: 'Maak nieuwe tijdregistratie aan',
      requestBody: {
        'employeeId': 'string',
        'date': 'string (YYYY-MM-DD)',
        'startTime': 'string (HH:mm)',
        'endTime': 'string (HH:mm)',
      },
      responseBody: {
        'id': 'string',
        'employeeId': 'string',
        'date': 'string (YYYY-MM-DD)',
        'startTime': 'string (HH:mm)',
        'endTime': 'string (HH:mm)',
        'status': 'string',
      },
    ),
    ApiEndpoint(
      path: '/registrations/{id}/approve',
      method: 'POST',
      description: 'Keur tijdregistratie goed',
      requestBody: {
        'note': 'string?',
        'approvedById': 'string',
      },
      responseBody: {
        'message': 'Registration approved successfully',
      },
    ),
    ApiEndpoint(
      path: '/registrations/{id}/reject',
      method: 'POST',
      description: 'Wijs tijdregistratie af',
      requestBody: {
        'note': 'string',
        'rejectedById': 'string',
      },
      responseBody: {
        'message': 'Registration rejected successfully',
      },
    ),
    ApiEndpoint(
      path: '/registrations/{id}',
      method: 'PUT',
      description: 'Update een tijdregistratie',
      requestBody: {
        'date': 'string (YYYY-MM-DD)?',
        'startTime': 'string (HH:mm)?',
        'endTime': 'string (HH:mm)?',
      },
      responseBody: {
        'id': 'string',
        'employeeId': 'string',
        'date': 'string (YYYY-MM-DD)',
        'startTime': 'string (HH:mm)',
        'endTime': 'string (HH:mm)',
        'status': 'string',
      },
    ),
    ApiEndpoint(
      path: '/registrations/{id}',
      method: 'DELETE',
      description: 'Verwijder een tijdregistratie',
      responseBody: {
        'message': 'Registration deleted successfully',
      },
    ),

    // Statistics Endpoints
    ApiEndpoint(
      path: '/statistics/yearly',
      method: 'GET',
      description: 'Haal jaarstatistieken op met filters',
      requestBody: {
        'year': 'number',
        'restaurantId': 'string?',
        'employeeId': 'string?',
      },
      responseBody: {
        'year': 'number',
        'totalHours': 'number',
        'monthlyHours': 'number[]',
        'employeeStats': [
          {
            'employeeId': 'string',
            'totalHours': 'number',
            'monthlyHours': 'number[]',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/statistics/monthly',
      method: 'GET',
      description: 'Haal maandstatistieken op',
      responseBody: {
        'year': 'number',
        'month': 'number',
        'totalHours': 'number',
        'dailyHours': 'number[]',
        'employeeStats': [
          {
            'employeeId': 'string',
            'totalHours': 'number',
            'dailyHours': 'number[]',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/statistics/weekly',
      method: 'GET',
      description: 'Haal weekstatistieken op',
      responseBody: {
        'year': 'number',
        'week': 'number',
        'totalHours': 'number',
        'dailyHours': 'number[]',
        'employeeStats': [
          {
            'employeeId': 'string',
            'totalHours': 'number',
            'dailyHours': 'number[]',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/statistics/export',
      method: 'POST',
      description: 'Exporteer statistieken',
      requestBody: {
        'format': 'string (pdf/csv/excel)',
        'periodType': 'string (year/month/week)',
        'year': 'number',
        'month': 'number?',
        'week': 'number?',
        'restaurantId': 'string?',
      },
      responseBody: {
        'downloadUrl': 'string',
        'expiresAt': 'string (ISO date)',
      },
    ),

    // User Profile endpoints
    ApiEndpoint(
      path: '/profile',
      method: 'GET',
      description: 'Haal profiel van huidige gebruiker op',
      responseBody: {
        'id': 'string',
        'name': 'string',
        'email': 'string',
        'role': 'string',
        'function': 'string',
        'restaurantId': 'string?',
        'preferences': {
          'language': 'string',
          'theme': 'string',
          'notifications': 'boolean',
        },
      },
    ),
    ApiEndpoint(
      path: '/profile',
      method: 'PUT',
      description: 'Update profiel van huidige gebruiker',
      requestBody: {
        'name': 'string?',
        'email': 'string?',
        'preferences': {
          'language': 'string?',
          'theme': 'string?',
          'notifications': 'boolean?',
        },
      },
      responseBody: {
        'message': 'Profile updated successfully',
      },
    ),

    // Password management
    ApiEndpoint(
      path: '/auth/password/reset',
      method: 'POST',
      description: 'Vraag wachtwoord reset aan',
      requestBody: {
        'email': 'string',
      },
      responseBody: {
        'message': 'Password reset email sent',
      },
    ),
    ApiEndpoint(
      path: '/auth/password/change',
      method: 'POST',
      description: 'Verander wachtwoord',
      requestBody: {
        'currentPassword': 'string',
        'newPassword': 'string',
        'confirmPassword': 'string',
      },
      responseBody: {
        'message': 'Password changed successfully',
      },
    ),

    // Restaurant management
    ApiEndpoint(
      path: '/restaurants/{id}/assign',
      method: 'POST',
      description: 'Wijs medewerker toe aan restaurant',
      requestBody: {
        'employeeId': 'string',
      },
      responseBody: {
        'message': 'Employee assigned successfully',
      },
    ),
    ApiEndpoint(
      path: '/restaurants/{id}/unassign',
      method: 'POST',
      description: 'Verwijder medewerker van restaurant',
      requestBody: {
        'employeeId': 'string',
      },
      responseBody: {
        'message': 'Employee unassigned successfully',
      },
    ),

    // Bulk operations
    ApiEndpoint(
      path: '/registrations/bulk/approve',
      method: 'POST',
      description: 'Keur meerdere tijdregistraties goed',
      requestBody: {
        'registrationIds': 'string[]',
        'note': 'string?',
        'approvedById': 'string',
      },
      responseBody: {
        'message': 'Registrations approved successfully',
        'processed': 'number',
        'failed': 'number',
      },
    ),

    // Filters en zoeken
    ApiEndpoint(
      path: '/employees/search',
      method: 'GET',
      description: 'Zoek medewerkers',
      requestBody: {
        'query': 'string',
        'restaurantId': 'string?',
        'role': 'string?',
        'isActive': 'boolean?',
      },
      responseBody: {
        'employees': [
          {
            'id': 'string',
            'name': 'string',
            'function': 'string',
            'role': 'string',
            'restaurantId': 'string?',
          }
        ],
      },
    ),

    // Notificaties
    ApiEndpoint(
      path: '/notifications',
      method: 'GET',
      description: 'Haal notificaties op',
      responseBody: {
        'notifications': [
          {
            'id': 'string',
            'type': 'string',
            'message': 'string',
            'isRead': 'boolean',
            'createdAt': 'string (ISO date)',
            'data': 'object?',
          }
        ],
      },
    ),
    ApiEndpoint(
      path: '/notifications/{id}/read',
      method: 'POST',
      description: 'Markeer notificatie als gelezen',
      responseBody: {
        'message': 'Notification marked as read',
      },
    ),
  ];

  const ApiDocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Documentation'),
      ),
      body: ListView.builder(
        itemCount: endpoints.length,
        itemBuilder: (context, index) {
          final endpoint = endpoints[index];
          return ExpansionTile(
            title: Text('${endpoint.method} ${endpoint.path}'),
            subtitle: Text(endpoint.description),
            children: [
              if (endpoint.requestBody != null)
                ListTile(
                  title: const Text('Request Body:'),
                  subtitle: Text(
                    endpoint.requestBody.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              if (endpoint.responseBody != null)
                ListTile(
                  title: const Text('Response Body:'),
                  subtitle: Text(
                    endpoint.responseBody.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
