import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/consultation_model.dart';
import '../../widgets/cosmic_background.dart';

class AiHoroscopeScreen extends StatefulWidget {
  const AiHoroscopeScreen({super.key});

  @override
  State<AiHoroscopeScreen> createState() => _AiHoroscopeScreenState();
}

class _AiHoroscopeScreenState extends State<AiHoroscopeScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'ai_1',
      senderId: 'ai',
      senderName: 'AstroDashaCare AI Guru',
      text: 'Namaste! I am your AI Astrological Assistant. Ask me about your Kundli transits, Gemstone recommendations, Vastu tips, or daily horoscope predictions.',
      timestamp: DateTime.now(),
      isAstrologer: true,
    ),
  ];

  void _sendAiPrompt() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user',
          senderName: 'You',
          text: text,
          timestamp: DateTime.now(),
          isAstrologer: false,
        ),
      );
      _promptController.clear();
      _isGenerating = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add(
            ChatMessage(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
              senderId: 'ai',
              senderName: 'AstroDashaCare AI Guru',
              text: 'Based on cosmic positioning, your current 10th house alignment favors career growth. Wearing Yellow Sapphire (Pukhraj) and chanting Vishnu Sahasranama on Thursdays will maximize divine clarity.',
              timestamp: DateTime.now(),
              isAstrologer: true,
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('AI Horoscope Assistant', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isAstrologer ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: msg.isAstrologer ? AppColors.cardSurface : AppColors.primaryGold.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: msg.isAstrologer ? AppColors.borderGold.withOpacity(0.4) : AppColors.lightGold),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  msg.isAstrologer ? Icons.smart_toy_rounded : Icons.person_rounded,
                                  size: 14,
                                  color: AppColors.lightGold,
                                ),
                                const SizedBox(width: 6),
                                Text(msg.senderName, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(msg.text, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, height: 1.4)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_isGenerating)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold)),
                      const SizedBox(width: 8),
                      Text('AI Guru is analyzing cosmic birth charts...', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightGold)),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(12),
                color: AppColors.backgroundMid,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask AI Horoscope Prediction...',
                          hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.lightGold),
                      onPressed: _sendAiPrompt,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
