import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/allergy_alert.dart';

/// Widget que muestra alertas de alergia cuando se detectan ingredientes alergénicos
/// según CAMBIOS_ENDPOINTS.md
class AllergyAlertWidget extends StatelessWidget {
  final List<AllergyAlert> allergyAlerts;
  final VoidCallback? onDismiss;

  const AllergyAlertWidget({
    super.key,
    required this.allergyAlerts,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (allergyAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '⚠️ ALERTA DE ALERGIA',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(Icons.close, color: colorScheme.error, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // Alert List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: allergyAlerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = allergyAlerts[index];
              return _buildAlertItem(alert, colorScheme);
            },
          ),

          // Footer message
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Por favor, revisa los ingredientes antes de consumir.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AllergyAlert alert, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name and confidence
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(alert.confidence * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Allergens
          if (alert.allergens.isNotEmpty) ...[
            Text(
              'Contiene:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children:
                  alert.allergens.map((allergen) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        allergen,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // Alert message
          Text(
            alert.message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar cuando hay alertas de alergia
class AllergyAlertBadge extends StatelessWidget {
  final int alertCount;
  final VoidCallback? onTap;

  const AllergyAlertBadge({super.key, required this.alertCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (alertCount == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '$alertCount alergia${alertCount > 1 ? 's' : ''} detectada${alertCount > 1 ? 's' : ''}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
