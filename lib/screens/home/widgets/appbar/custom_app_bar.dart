import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urcs/providers/time_registration_provider.dart';
import 'package:urcs/models/permission.dart' as perm;
import 'package:urcs/models/employee.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Update de tijd elke seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  void _navigateToScreen(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    // Voorkom onnodige navigatie
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Voorkom sluiten door buiten te klikken
      builder: (context) => AlertDialog(
        title: const Text('Uitloggen'),
        content: const Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Provider.of<TimeRegistrationProvider>(context, listen: false)
                  .logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Uitloggen'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String route) {
    return TextButton(
      onPressed: () => _navigateToScreen(context, route),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(title),
    );
  }

  Widget _buildTimeDisplay(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          DateFormat('HH:mm').format(_currentTime),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat('EEEE', 'nl_NL').format(_currentTime).toLowerCase(),
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onPrimary.withAlpha(204),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, Employee currentEmployee) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            currentEmployee.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        label: Text(currentEmployee.name),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          value: 'info',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentEmployee.function,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currentEmployee.role.toString().split('.').last,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: () => _handleLogout(context),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Uitloggen',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Als de breedte kleiner is dan 600, toon een eenvoudige AppBar voor mobiele schermen
    if (isMobile) {
      return AppBar(
        title: const Text('URCS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      );
    }

    final provider = Provider.of<TimeRegistrationProvider>(context);
    final canManageRestaurants =
        provider.hasPermission(perm.Permission.addRestaurant);
    final currentEmployee = provider.currentEmployee;

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      toolbarHeight: 90,
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildMenuItem(context, 'Urenlijst', '/'),
              _buildMenuItem(context, 'Jaaroverzicht', '/annual-overview'),
              if (canManageRestaurants)
                _buildMenuItem(context, 'Restaurants', '/restaurants'),
              _buildMenuItem(context, 'Medewerkers', '/employees'),
              const Spacer(),
            ],
          ),
          _buildTimeDisplay(context),
        ],
      ),
      actions: [
        if (currentEmployee != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildUserMenu(context, currentEmployee),
          ),
      ],
    );
  }
}
