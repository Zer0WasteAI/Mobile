import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';

/// Onboarding state
class OnboardingState {
  /// Current page index
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Whether onboarding has been seen
  final bool onboardingSeen;

  /// Constructor
  const OnboardingState({
    this.currentPage = 0,
    this.totalPages = 5,
    this.onboardingSeen = false,
  });

  /// Copy with
  OnboardingState copyWith({
    int? currentPage,
    int? totalPages,
    bool? onboardingSeen,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    );
  }

  /// Is last page
  bool get isLastPage => currentPage == totalPages - 1;
}

/// Onboarding controller
class OnboardingController extends StateNotifier<OnboardingState> {
  /// Constructor
  OnboardingController({
    required this.setOnboardingSeenUseCase,
  }) : super(const OnboardingState());

  /// Set onboarding seen use case
  final SetOnboardingSeenUseCase setOnboardingSeenUseCase;

  /// Update current page
  void updatePage(int page) {
    state = state.copyWith(currentPage: page);
  }

  /// Set onboarding as seen
  Future<void> setOnboardingSeen() async {
    await setOnboardingSeenUseCase(const NoParams());
    state = state.copyWith(onboardingSeen: true);
  }

  /// Next page
  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }
}

/// Provider for onboarding controller
final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final setOnboardingSeenUseCase = ref.watch(setOnboardingSeenUseCaseProvider);
  return OnboardingController(
    setOnboardingSeenUseCase: setOnboardingSeenUseCase,
  );
});
