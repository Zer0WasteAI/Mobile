// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';

/// INFO: Main user profile provider - FIRESTORE ONLY
/// USAGE: Use for complete profile management with Firestore
/// ADVICE: This is the primary provider for all profile operations - no backend needed

// Profile state
class UserProfileState {
  final UserModel? user;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isBackendSynced;

  const UserProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isBackendSynced = false,
  });

  UserProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isBackendSynced,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      isBackendSynced: isBackendSynced ?? this.isBackendSynced,
    );
  }
}

/// INFO: User profile notifier with backend integration
/// USAGE: Manages complete user profile with backend synchronization
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final AuthRepository _authRepository;

  UserProfileNotifier(this._authRepository) : super(const UserProfileState()) {
    // No longer calling _initializeProfile - initialization handled by provider
  }

  /// INFO: Refresh profile from current auth state - FIRESTORE ONLY
  /// USAGE: Refreshes profile data from auth state
  Future<void> refreshProfile() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        isBackendSynced: true,
      );
    }
  }

  /// INFO: Update user preferences - FIRESTORE ONLY
  /// USAGE: Update any user preference and sync to Firestore only
  Future<void> updatePreferences(UserPreferencesModel newPrefs) async {
    if (state.user == null) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      // Update locally first
      final updatedUser = state.user!.copyWith(prefs: newPrefs);
      state = state.copyWith(user: updatedUser);

      // Update in Firestore only (no backend calls)
      if (newPrefs.cookingLevel != null) {
        await _authRepository.saveUserCookingLevel(newPrefs.cookingLevel!);
      }
      await _authRepository.saveUserLanguage(newPrefs.language);
      await _authRepository.saveUserAllergyItems(newPrefs.allergies);
      await _authRepository.saveUserSpecialDietItems(newPrefs.specialDiets);
      await _authRepository.saveUserPreferredFoodTypes(
        newPrefs.preferredFoodTypes,
      );

      state = state.copyWith(isSaving: false, isBackendSynced: true);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
        isBackendSynced: false,
      );
    }
  }

  /// INFO: Update basic profile info (name, photo)
  /// USAGE: Update display name or profile photo
  Future<void> updateBasicProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      // Update through auth repository (handles Firebase + backend)
      await _authRepository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Update local state
      final updatedUser = state.user!.copyWith(
        displayName: displayName ?? state.user!.displayName,
        photoURL: photoURL ?? state.user!.photoURL,
      );

      state = state.copyWith(
        user: updatedUser,
        isSaving: false,
        isBackendSynced: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
        isBackendSynced: false,
      );
    }
  }

  /// INFO: Update specific preference type
  /// ADVICE: Use these methods for individual preference updates

  Future<void> updateCookingLevel(String cookingLevel) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(cookingLevel: cookingLevel);
    await updatePreferences(newPrefs);
  }

  Future<void> updateLanguage(String language) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(language: language);
    await updatePreferences(newPrefs);
  }

  Future<void> updateAllergies(List<String> allergies) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(allergies: allergies);
    await updatePreferences(newPrefs);
  }

  Future<void> updateSpecialDiets(List<String> diets) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(specialDiets: diets);
    await updatePreferences(newPrefs);
  }

  Future<void> updatePreferredFoodTypes(List<String> foodTypes) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(preferredFoodTypes: foodTypes);
    await updatePreferences(newPrefs);
  }

  /// INFO: Update structured preference items
  /// ADVICE: Use these for rich preference data with emojis and metadata

  Future<void> updateAllergyItems(
    List<Map<String, dynamic>> allergyItems,
  ) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(allergyItems: allergyItems);
    await updatePreferences(newPrefs);
  }

  Future<void> updateSpecialDietItems(
    List<Map<String, dynamic>> dietItems,
  ) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(specialDietItems: dietItems);
    await updatePreferences(newPrefs);
  }

  Future<void> updatePreferredFoodTypeItems(
    List<Map<String, dynamic>> foodTypeItems,
  ) async {
    if (state.user == null) return;

    final newPrefs = state.user!.prefs.copyWith(
      preferredFoodTypeItems: foodTypeItems,
    );
    await updatePreferences(newPrefs);
  }

  /// INFO: Mark initial preferences as completed - FIRESTORE ONLY
  /// USAGE: Call when user finishes onboarding preferences
  Future<void> markPreferencesCompleted() async {
    if (state.user == null) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      // Update in Firestore only (no backend call)
      await _authRepository.markInitialPreferencesCompleted();

      // Update local state
      final updatedUser = state.user!.copyWith(
        initialPreferencesCompleted: true,
      );
      state = state.copyWith(
        user: updatedUser,
        isSaving: false,
        isBackendSynced: true,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  /// INFO: Force refresh from backend
  /// USAGE: Call to ensure data is up-to-date
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      // Force refresh from Firestore
      await _authRepository.refreshUserFromFirestore();
      await refreshProfile();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void setUser(UserModel user) {
    print('🔧 UserProfileProvider: Setting user - ${user.displayName}');
    print('🔧 Preferences loaded:');
    print('  - cookingLevel: ${user.prefs.cookingLevel}');
    print('  - allergies: ${user.prefs.allergies}');
    print('  - specialDiets: ${user.prefs.specialDiets}');
    print('  - preferredFoodTypes: ${user.prefs.preferredFoodTypes}');
    state = state.copyWith(user: user, isBackendSynced: true);
  }

  void clearUser() {
    print('🔧 UserProfileProvider: Clearing user');
    state = state.copyWith(user: null, isBackendSynced: false);
  }
}

/// INFO: Main user profile provider
/// USAGE: Use ref.watch(userProfileProvider) to get current profile state
final userProfileProvider = StateNotifierProvider<
  UserProfileNotifier,
  UserProfileState
>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final notifier = UserProfileNotifier(authRepository);

  // Initialize with current auth state immediately
  final authState = ref.read(authStateProvider);
  authState.whenData((user) {
    if (user != null) {
      print('🔧 UserProfileProvider: Initial user set - ${user.displayName}');
      notifier.setUser(user);
    }
  });

  // Listen to auth state changes to get user with Firestore data
  ref.listen(authStateProvider, (previous, next) {
    print('🔧 UserProfileProvider: Auth state changed');
    next.whenData((user) {
      if (user != null) {
        print(
          '🔧 UserProfileProvider: Auth state updated with user - ${user.displayName}',
        );
        notifier.setUser(user);
      } else {
        print('🔧 UserProfileProvider: Auth state cleared user');
        notifier.clearUser();
      }
    });
  });

  return notifier;
});

/// INFO: Convenient providers for specific profile data
/// ADVICE: Use these for easier access to specific profile information

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProfileProvider).user;
});

final userPreferencesProvider = Provider<UserPreferencesModel>((ref) {
  return ref.watch(userProfileProvider).user?.prefs ??
      const UserPreferencesModel();
});

final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isLoading;
});

final isProfileSavingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isSaving;
});

final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).error;
});

final isBackendSyncedProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isBackendSynced;
});
