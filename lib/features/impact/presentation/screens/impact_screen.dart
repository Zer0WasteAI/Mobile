import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_dashboard_tab.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_progress_tab.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_tab_bar.dart';

/// Pantalla principal del Panel de Impacto Ambiental
class ImpactScreen extends ConsumerStatefulWidget {
  const ImpactScreen({super.key});

  @override
  ConsumerState<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends ConsumerState<ImpactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Sincronizar el controlador con el estado de Riverpod
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(impactTabIndexProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;

    // Asegurar que el controlador de tabs está sincronizado con el estado
    final selectedTabIndex = ref.watch(impactTabIndexProvider);
    if (_tabController.index != selectedTabIndex) {
      _tabController.animateTo(selectedTabIndex);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            try {
              // Intentar regresar a la pantalla anterior
              context.pop();
            } catch (e) {
              // Si no hay pantalla anterior, ir a la pantalla de inicio
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Panel de Impacto',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // Barra de pestañas
          ImpactTabBar(tabController: _tabController),
          const SizedBox(height: 16),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Pestaña de Mi Impacto
                ImpactDashboardTab(),

                // Pestaña de Progreso
                ImpactProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
