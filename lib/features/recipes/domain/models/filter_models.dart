import 'package:flutter/material.dart'; // For IconData parsing

// Rename FilterOption to Filter to match the class used in our implementation
class Filter {
  final String label;
  final String value;
  final IconData? icon;

  Filter({required this.label, required this.value, this.icon});

  factory Filter.fromJson(Map<String, dynamic> json) {
    IconData? iconData;

    // Convert string icon name to IconData
    if (json.containsKey('icon') && json['icon'] != null) {
      // Map common icon names to IconData
      switch (json['icon']) {
        case 'restaurant_menu':
          iconData = Icons.restaurant_menu;
          break;
        case 'dinner_dining':
          iconData = Icons.dinner_dining;
          break;
        case 'icecream':
          iconData = Icons.icecream;
          break;
        case 'local_cafe':
          iconData = Icons.local_cafe;
          break;
        case 'emoji_food_beverage':
          iconData = Icons.emoji_food_beverage;
          break;
        case 'timer':
          iconData = Icons.timer;
          break;
        case 'schedule':
          iconData = Icons.schedule;
          break;
        case 'hourglass_bottom':
          iconData = Icons.hourglass_bottom;
          break;
        case 'fitness_center':
          iconData = Icons.fitness_center;
          break;
        case 'whatshot':
          iconData = Icons.whatshot;
          break;
        case 'lunch_dining':
          iconData = Icons.lunch_dining;
          break;
        case 'eco':
          iconData = Icons.eco;
          break;
        case 'spa':
          iconData = Icons.spa;
          break;
        case 'restaurant':
          iconData = Icons.restaurant;
          break;
        case 'no_food':
          iconData = Icons.no_food;
          break;
        case 'water_drop':
          iconData = Icons.water_drop;
          break;
        case 'free_breakfast':
          iconData = Icons.free_breakfast;
          break;
        case 'recycling':
          iconData = Icons.recycling;
          break;
        case 'sunny':
          iconData = Icons.sunny;
          break;
        case 'compost':
          iconData = Icons.compost;
          break;
        case 'light_mode':
          iconData = Icons.light_mode;
          break;
        case 'star_half':
          iconData = Icons.star_half;
          break;
        case 'grade':
          iconData = Icons.grade;
          break;
        case 'attach_money':
          iconData = Icons.attach_money;
          break;
        case 'payments':
          iconData = Icons.payments;
          break;
        case 'monetization_on':
          iconData = Icons.monetization_on;
          break;
        default:
          iconData = null;
      }
    }

    return Filter(
      label: json['label'] as String,
      value: json['value'] as String,
      icon: iconData,
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'icon': icon?.toString()};
  }
}

// Represents a category of filters (e.g., 'Tipo de receta')
class FilterCategory {
  final String category;
  final List<Filter> filters;

  FilterCategory({required this.category, required this.filters});

  factory FilterCategory.fromJson(Map<String, dynamic> json) {
    var filtersList = json['filters'] as List;
    List<Filter> filterOptions =
        filtersList
            .map(
              (filterJson) =>
                  Filter.fromJson(filterJson as Map<String, dynamic>),
            )
            .toList();

    return FilterCategory(
      category: json['category'] as String,
      filters: filterOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'filters': filters.map((filter) => filter.toJson()).toList(),
    };
  }
}
