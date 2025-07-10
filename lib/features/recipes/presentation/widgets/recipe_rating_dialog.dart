import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeRatingDialog extends StatefulWidget {
  final String recipeName;
  final Function(int rating, String comment) onSubmit;

  const RecipeRatingDialog({
    super.key,
    required this.recipeName,
    required this.onSubmit,
  });

  @override
  State<RecipeRatingDialog> createState() => _RecipeRatingDialogState();
}

class _RecipeRatingDialogState extends State<RecipeRatingDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF3A3A3A);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confetti icon
            const Icon(Icons.celebration, color: Colors.amber, size: 48),
            const SizedBox(height: 16),

            // Title
            Text(
              '¡Felicidades!',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Has completado la receta:',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: textColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Recipe name
            Text(
              widget.recipeName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Rating stars
            Text(
              '¿Cómo te quedó?',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),

            // Comment field
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '¿Algún comentario? (opcional)',
                hintStyle: GoogleFonts.inter(
                  color: textColor.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: isDark ? Colors.black12 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.inter(color: textColor),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Omitir',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      _rating > 0
                          ? () {
                            widget.onSubmit(_rating, _commentController.text);
                            /*Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);*/
                            Navigator.pop(context);
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Enviar',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
