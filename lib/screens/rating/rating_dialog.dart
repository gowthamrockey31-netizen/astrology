import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/astrologer_model.dart';

class RatingDialog extends StatefulWidget {
  final AstrologerModel astrologer;
  final Function(int rating, String comment) onSubmit;

  const RatingDialog({
    super.key,
    required this.astrologer,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedStars = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderGold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(widget.astrologer.photoUrl),
            ),
            const SizedBox(height: 12),
            Text(
              'Rate Consultation',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'How was your divine session with ${widget.astrologer.name}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 16),

            // 5 Star Rating Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1;
                return IconButton(
                  icon: Icon(
                    starVal <= _selectedStars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.lightGold,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _selectedStars = starVal),
                );
              }),
            ),

            const SizedBox(height: 14),

            // Comment Box
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write a review or feedback...',
                hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onSubmit(_selectedStars, _commentController.text.trim());
                },
                child: Text(
                  'Submit Review',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
