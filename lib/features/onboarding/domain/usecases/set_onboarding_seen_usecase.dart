import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/local_storage/shared_prefs_helper.dart';
import 'package:zer0_waste_ai/core/usecases/usecase.dart';

/// Key for storing onboarding seen state in SharedPreferences
const String kOnboardingSeenKey = 'onboarding_seen';

/// Provider for SetOnboardingSeenUseCase
final setOnboardingSeenUseCaseProvider = Provider<SetOnboardingSeenUseCase>((ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider);
  return SetOnboardingSeenUseCase(sharedPrefs);
});

/// Provider for checking if onboarding has been seen
final onboardingSeenProvider = Provider<bool>((ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider);
  return sharedPrefs.getBool(kOnboardingSeenKey) ?? false;
});

/// UseCase for setting onboarding seen state
class SetOnboardingSeenUseCase implements UseCase<bool, NoParams> {
  /// Constructor
  const SetOnboardingSeenUseCase(this._sharedPrefs);

  final SharedPreferencesHelper _sharedPrefs;

  @override
  Future<bool> call(NoParams params) async {
    return await _sharedPrefs.setBool(kOnboardingSeenKey, true);
  }
}

/// UseCase for getting onboarding seen state
class GetOnboardingSeenUseCase implements UseCase<bool, NoParams> {
  /// Constructor
  const GetOnboardingSeenUseCase(this._sharedPrefs);

  final SharedPreferencesHelper _sharedPrefs;

  @override
  Future<bool> call(NoParams params) async {
    return _sharedPrefs.getBool(kOnboardingSeenKey) ?? false;
  }
}

/// Provider for GetOnboardingSeenUseCase
final getOnboardingSeenUseCaseProvider = Provider<GetOnboardingSeenUseCase>((ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider);
  return GetOnboardingSeenUseCase(sharedPrefs);
});