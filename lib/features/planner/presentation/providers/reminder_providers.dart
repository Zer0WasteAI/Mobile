/// INFO: Providers for reminder functionality
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/reminder_service.dart';
import '../../domain/models/reminder_models.dart';
import '../../domain/models/meal_plan_models.dart';

/// Provider for the reminder service singleton
final reminderServiceProvider = Provider<ReminderService>((ref) {
  final service = ReminderService();
  service.initialize();
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Stream provider for triggered reminders
final reminderStreamProvider = StreamProvider<MealReminder>((ref) {
  final service = ref.watch(reminderServiceProvider);
  return service.reminderStream;
});

/// Provider for all active reminders
final activeRemindersProvider = StateNotifierProvider<ActiveRemindersNotifier, List<MealReminder>>((ref) {
  final service = ref.watch(reminderServiceProvider);
  return ActiveRemindersNotifier(service);
});

/// State notifier for managing active reminders
class ActiveRemindersNotifier extends StateNotifier<List<MealReminder>> {
  final ReminderService _reminderService;

  ActiveRemindersNotifier(this._reminderService) : super([]) {
    _loadReminders();
  }

  void _loadReminders() {
    state = _reminderService.activeReminders;
  }

  /// Add a new reminder
  void addReminder(MealReminder reminder) {
    _reminderService.addReminder(reminder);
    _loadReminders();
  }

  /// Add multiple reminders
  void addReminders(List<MealReminder> reminders) {
    _reminderService.addReminders(reminders);
    _loadReminders();
  }

  /// Remove a reminder
  void removeReminder(String reminderId) {
    _reminderService.removeReminder(reminderId);
    _loadReminders();
  }

  /// Update a reminder
  void updateReminder(String reminderId, MealReminder updatedReminder) {
    _reminderService.updateReminder(reminderId, updatedReminder);
    _loadReminders();
  }

  /// Create default reminders for a meal
  void createRemindersForMeal({
    required SimpleRecipe recipe,
    required DateTime mealTime,
    List<ReminderType>? reminderTypes,
  }) {
    _reminderService.createRemindersForMealPlan(
      recipe: recipe,
      mealTime: mealTime,
      reminderTypes: reminderTypes,
    );
    _loadReminders();
  }

  /// Remove all reminders for a recipe
  void removeRemindersForRecipe(String recipeId) {
    _reminderService.removeRemindersForRecipe(recipeId);
    _loadReminders();
  }

  /// Clear all reminders
  void clearAllReminders() {
    _reminderService.clearAllReminders();
    _loadReminders();
  }
}

/// Provider for upcoming reminders (next 24 hours)
final upcomingRemindersProvider = Provider<List<MealReminder>>((ref) {
  ref.watch(activeRemindersProvider); // Watch for changes
  final service = ref.watch(reminderServiceProvider);
  return service.getUpcomingReminders();
});

/// Provider for reminders by date
final remindersByDateProvider = Provider.family<List<MealReminder>, DateTime>((ref, date) {
  ref.watch(activeRemindersProvider); // Watch for changes
  final service = ref.watch(reminderServiceProvider);
  return service.getRemindersForDate(date);
});

/// Provider for reminders by recipe
final remindersByRecipeProvider = Provider.family<List<MealReminder>, String>((ref, recipeId) {
  ref.watch(activeRemindersProvider); // Watch for changes
  final service = ref.watch(reminderServiceProvider);
  return service.getRemindersForRecipe(recipeId);
});

/// Provider for reminder statistics
final reminderStatsProvider = Provider<Map<String, int>>((ref) {
  ref.watch(activeRemindersProvider); // Watch for changes
  final service = ref.watch(reminderServiceProvider);
  return service.getReminderStats();
});

/// Provider for reminder creation state
final reminderCreationStateProvider = StateProvider<ReminderCreationState>((ref) {
  return ReminderCreationState();
});

/// State class for reminder creation
class ReminderCreationState {
  final ReminderType selectedType;
  final Duration selectedBeforeTime;
  final String customTitle;
  final String customMessage;
  final bool isCustomTime;

  const ReminderCreationState({
    this.selectedType = ReminderType.cooking,
    this.selectedBeforeTime = const Duration(minutes: 30),
    this.customTitle = '',
    this.customMessage = '',
    this.isCustomTime = false,
  });

  ReminderCreationState copyWith({
    ReminderType? selectedType,
    Duration? selectedBeforeTime,
    String? customTitle,
    String? customMessage,
    bool? isCustomTime,
  }) {
    return ReminderCreationState(
      selectedType: selectedType ?? this.selectedType,
      selectedBeforeTime: selectedBeforeTime ?? this.selectedBeforeTime,
      customTitle: customTitle ?? this.customTitle,
      customMessage: customMessage ?? this.customMessage,
      isCustomTime: isCustomTime ?? this.isCustomTime,
    );
  }
}

/// Provider for reminder settings
final reminderSettingsProvider = StateNotifierProvider<ReminderSettingsNotifier, ReminderSettings>((ref) {
  return ReminderSettingsNotifier();
});

/// Settings for reminders
class ReminderSettings {
  final bool enabled;
  final bool allowNotifications;
  final List<ReminderType> defaultTypes;
  final Duration defaultShoppingTime;
  final Duration defaultPrepTime;
  final Duration defaultCookingTime;

  const ReminderSettings({
    this.enabled = true,
    this.allowNotifications = true,
    this.defaultTypes = const [
      ReminderType.shopping,
      ReminderType.prepping,
      ReminderType.cooking,
    ],
    this.defaultShoppingTime = const Duration(days: 1),
    this.defaultPrepTime = const Duration(hours: 2),
    this.defaultCookingTime = const Duration(minutes: 30),
  });

  ReminderSettings copyWith({
    bool? enabled,
    bool? allowNotifications,
    List<ReminderType>? defaultTypes,
    Duration? defaultShoppingTime,
    Duration? defaultPrepTime,
    Duration? defaultCookingTime,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      defaultTypes: defaultTypes ?? this.defaultTypes,
      defaultShoppingTime: defaultShoppingTime ?? this.defaultShoppingTime,
      defaultPrepTime: defaultPrepTime ?? this.defaultPrepTime,
      defaultCookingTime: defaultCookingTime ?? this.defaultCookingTime,
    );
  }
}

/// State notifier for reminder settings
class ReminderSettingsNotifier extends StateNotifier<ReminderSettings> {
  ReminderSettingsNotifier() : super(const ReminderSettings());

  void updateSettings(ReminderSettings newSettings) {
    state = newSettings;
  }

  void toggleEnabled() {
    state = state.copyWith(enabled: !state.enabled);
  }

  void toggleNotifications() {
    state = state.copyWith(allowNotifications: !state.allowNotifications);
  }

  void updateDefaultTypes(List<ReminderType> types) {
    state = state.copyWith(defaultTypes: types);
  }

  void updateDefaultTimes({
    Duration? shopping,
    Duration? prep,
    Duration? cooking,
  }) {
    state = state.copyWith(
      defaultShoppingTime: shopping,
      defaultPrepTime: prep,
      defaultCookingTime: cooking,
    );
  }
}