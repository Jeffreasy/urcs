import 'package:flutter/material.dart';
import '../home/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/time_registration_provider.dart';
import '../../models/restaurant.dart';
import '../../models/role.dart';
import 'add_restaurant_dialog.dart';
import 'edit_restaurant_dialog.dart';

class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  void _showEditDialog(BuildContext context, Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => EditRestaurantDialog(
        restaurant: restaurant,
        isNew: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeRegistrationProvider>(context);
    final restaurants = provider.restaurants;
    final isSuperAdmin = provider.currentEmployee?.role == Role.superAdmin;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header sectie
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurants',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    Text(
                      '${restaurants.length} vestigingen',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
                if (isSuperAdmin)
                  FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddRestaurantDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nieuw Restaurant'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Restaurants lijst
            Expanded(
              child: restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Geen restaurants gevonden',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          if (isSuperAdmin) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Klik op "Nieuw Restaurant" om te beginnen',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isSuperAdmin
                                ? () {
                                    _showEditDialog(context, restaurant);
                                  }
                                : null,
                            child: Column(
                              children: [
                                // Header met status
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withAlpha(76),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        restaurant.isActive
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: restaurant.isActive
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        restaurant.isActive
                                            ? 'Actief'
                                            : 'Inactief',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: restaurant.isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Bovenste rij met naam en acties
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            child: Text(
                                              restaurant.name[0].toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  restaurant.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                Text(
                                                  'ID: ${restaurant.id}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .outline,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSuperAdmin) ...[
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined),
                                              onPressed: () {
                                                _showEditDialog(
                                                    context, restaurant);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Restaurant Verwijderen'),
                                                    content: Text(
                                                      'Weet je zeker dat je "${restaurant.name}" wilt verwijderen?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: const Text(
                                                            'Annuleren'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () {
                                                          provider
                                                              .deleteRestaurant(
                                                                  restaurant
                                                                      .id);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error,
                                                        ),
                                                        child: const Text(
                                                            'Verwijderen'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ],
                                      ),

                                      const SizedBox(height: 16),
                                      const Divider(),
                                      const SizedBox(height: 16),

                                      // Basis informatie
                                      Text(
                                        'Basis Informatie',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Contact informatie in grid
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                _InfoTile(
                                                  icon: Icons
                                                      .location_on_outlined,
                                                  label: 'Adres',
                                                  value: restaurant
                                                          .address.isNotEmpty
                                                      ? restaurant.address
                                                      : 'Niet ingesteld',
                                                  maxLines: 2,
                                                ),
                                                const SizedBox(height: 12),
                                                _InfoTile(
                                                  icon: Icons.phone_outlined,
                                                  label: 'Telefoon',
                                                  value: restaurant.phoneNumber
                                                          .isNotEmpty
                                                      ? restaurant.phoneNumber
                                                      : 'Niet ingesteld',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                _InfoTile(
                                                  icon: Icons.email_outlined,
                                                  label: 'E-mail',
                                                  value: restaurant
                                                          .email.isNotEmpty
                                                      ? restaurant.email
                                                      : 'Niet ingesteld',
                                                ),
                                                const SizedBox(height: 12),
                                                _InfoTile(
                                                  icon: Icons.people_outline,
                                                  label: 'Medewerkers',
                                                  value:
                                                      '${restaurant.employees.length}',
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16),
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/employees',
                                                        arguments: {
                                                          'restaurantId':
                                                              restaurant.id,
                                                          'restaurantName':
                                                              restaurant.name,
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final int? maxLines;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: maxLines,
                overflow: maxLines != null ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
