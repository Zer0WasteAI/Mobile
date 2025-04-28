import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/allergy.dart';

// Asynchronous provider to load allergies from assets
final allergiesProvider = FutureProvider<List<Allergy>>((ref) async {
  try {
    final jsonString = await rootBundle.loadString(
      'lib/core/constants/allergies.json',
    );
    final List<dynamic> allergyList = jsonDecode(jsonString)['allergies'];
    return allergyList
        .map((data) => Allergy.fromJson(data as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Handle potential errors during file loading or parsing
    print("Error loading allergies from JSON: $e");
    // Return an empty list or throw an error, depending on desired behavior
    return [];
  }
});
