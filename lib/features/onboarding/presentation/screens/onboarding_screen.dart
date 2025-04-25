import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/viewmodels/onboarding_controller.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/widgets/custom_dot_indicator.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/widgets/next_button.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/widgets/onboarding_page.dart';

/// Onboarding screen
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Constructor
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // Page controller
  final PageController _pageController = PageController();

  // Onboarding data
  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboarding/onboarding_1.png',
      'title': 'Bienvenido a Zero Waste AI',
      'description': 'Transforma tu cocina en un espacio inteligente. Empieza a reducir el desperdicio de alimentos de manera sencilla.',
    },
    {
      'image': 'assets/images/onboarding/onboarding_2.png',
      'title': 'Escanea tus ingredientes',
      'description': 'Toma una foto de tus alimentos y deja que la inteligencia artificial los identifique por ti.',
    },
    {
      'image': 'assets/images/onboarding/onboarding_3.png',
      'title': 'Recibe recetas personalizadas',
      'description': 'Obtén sugerencias de recetas basadas en lo que ya tienes en casa.',
    },
    {
      'image': 'assets/images/onboarding/onboarding_4.png',
      'title': 'Organiza y planifica tus comidas',
      'description': 'Controla tu despensa, planea tus menús semanales y evita que la comida se pierda.',
    },
    {
      'image': 'assets/images/onboarding/onboarding_5.png',
      'title': 'Haz seguimiento de tu impacto',
      'description': 'Descubre cuánto has ahorrado y cómo ayudas al planeta reduciendo el desperdicio.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);
    final onboardingController = ref.read(onboardingControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => _completeOnboarding(context, onboardingController),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  onboardingController.updatePage(index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    imagePath: page['image']!,
                    title: page['title']!,
                    description: page['description']!,
                  );
                },
              ),
            ),

            // Bottom section with indicators and button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dot indicator
                  CustomDotIndicator(
                    controller: _pageController,
                    count: _pages.length,
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started button
                  NextButton(
                    isLastPage: onboardingState.isLastPage,
                    onPressed: () {
                      if (onboardingState.isLastPage) {
                        _completeOnboarding(context, onboardingController);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Complete onboarding and navigate to login
  void _completeOnboarding(BuildContext context, OnboardingController controller) async {
    await controller.setOnboardingSeen();
    if (context.mounted) {
      context.go('/login');
    }
  }
}