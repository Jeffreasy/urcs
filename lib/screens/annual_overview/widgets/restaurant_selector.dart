import 'package:flutter/material.dart';
import '../../../models/restaurant.dart';

class RestaurantSelector extends StatelessWidget {
  final String? selectedRestaurantId;
  final List<Restaurant> restaurants;
  final ValueChanged<String?> onRestaurantChanged;

  const RestaurantSelector({
    super.key,
    required this.selectedRestaurantId,
    required this.restaurants,
    required this.onRestaurantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: selectedRestaurantId,
      decoration: InputDecoration(
        labelText: 'Restaurant',
        hintText: 'Selecteer een restaurant',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.restaurant),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Alle Restaurants'),
        ),
        ...restaurants.map((restaurant) {
          return DropdownMenuItem(
            value: restaurant.id,
            child: Text(restaurant.name),
          );
        }),
      ],
      onChanged: onRestaurantChanged,
    );
  }
}
