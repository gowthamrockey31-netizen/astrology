import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/astrologer_model.dart';
import '../../widgets/cosmic_background.dart';

class CallQueueScreen extends StatefulWidget {
  final AstrologerModel astrologer;
  final String type;
  final VoidCallback onAvailable;

  const CallQueueScreen({
    super.key,
    required this.astrologer,
    required this.type,
    required this.onAvailable,
  });

  @override
  State<CallQueueScreen> createState() => _CallQueueScreenState();
}

class _CallQueueScreenState extends State<CallQueueScreen> {
  int _queuePosition = 2;
  int _secondsLeft = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        _timer.cancel();
        if (mounted) {
          widget.onAvailable();
        }
      } else {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft == 5) {
            _queuePosition = 1;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.astrologer.photoUrl),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 1200.ms),

                const SizedBox(height: 24),

                Text(
                  widget.astrologer.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Busy Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: Colors.orangeAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'The astrologer is currently assisting another customer.',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Queue Position Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('QUEUE POSITION', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text('#$_queuePosition', style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      Column(
                        children: [
                          Text('ESTIMATED WAIT', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text('${_secondsLeft}s', style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.cyanAccent)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  '🔔 You will receive a push notification automatically when ${widget.astrologer.name} accepts your call.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
