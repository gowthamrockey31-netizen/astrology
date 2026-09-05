import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_horoscope_service.dart';
import '../../widgets/cosmic_background.dart';

class AiHoroscopeMessageItem {
  final String id;
  final String senderId;
  final String senderName;
  String text;
  final DateTime timestamp;
  final bool isAstrologer;
  bool isTranslated;
  String? originalText;

  AiHoroscopeMessageItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isAstrologer,
    this.isTranslated = false,
    this.originalText,
  });
}

class AiHoroscopeScreen extends StatefulWidget {
  const AiHoroscopeScreen({super.key});

  @override
  State<AiHoroscopeScreen> createState() => _AiHoroscopeScreenState();
}

class _AiHoroscopeScreenState extends State<AiHoroscopeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;
  HoroscopeLanguage _selectedLanguage = HoroscopeLanguage.tamil;

  final List<AiHoroscopeMessageItem> _messages = [];

  @override
  void initState() {
    super.initState();
    _resetWelcomeMessage();
  }

  void _resetWelcomeMessage() {
    _messages.clear();
    _messages.add(
      AiHoroscopeMessageItem(
        id: 'ai_welcome',
        senderId: 'ai',
        senderName: _selectedLanguage == HoroscopeLanguage.tamil
            ? 'AstroDashaCare AI குரு'
            : 'AstroDashaCare AI Guru',
        text: AiHoroscopeService.getWelcomeMessage(_selectedLanguage),
        timestamp: DateTime.now(),
        isAstrologer: true,
      ),
    );
  }

  void _toggleLanguage(HoroscopeLanguage newLang) {
    if (_selectedLanguage == newLang) return;
    setState(() {
      _selectedLanguage = newLang;
      // If only welcome message is present, refresh it to the new language
      if (_messages.length == 1 && _messages.first.id == 'ai_welcome') {
        _resetWelcomeMessage();
      }
    });

    final msg = newLang == HoroscopeLanguage.tamil
        ? 'மொழி தமிழுக்கு மாற்றப்பட்டது (Language: Tamil)'
        : 'Language switched to English';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(color: AppColors.lightGold)),
        backgroundColor: AppColors.cardSurfaceLight,
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendAiPrompt({String? customText}) {
    final text = customText ?? _promptController.text.trim();
    if (text.isEmpty) return;

    final userLang = _selectedLanguage;

    setState(() {
      _messages.add(
        AiHoroscopeMessageItem(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user',
          senderName: userLang == HoroscopeLanguage.tamil ? 'நீங்கள்' : 'You',
          text: text,
          timestamp: DateTime.now(),
          isAstrologer: false,
        ),
      );
      if (customText == null) {
        _promptController.clear();
      }
      _isGenerating = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final advice = AiHoroscopeService.generateAdvice(text, userLang);
      setState(() {
        _isGenerating = false;
        _messages.add(
          AiHoroscopeMessageItem(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'ai',
            senderName: userLang == HoroscopeLanguage.tamil
                ? 'AstroDashaCare AI குரு'
                : 'AstroDashaCare AI Guru',
            text: advice,
            timestamp: DateTime.now(),
            isAstrologer: true,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _translateMessage(AiHoroscopeMessageItem msg) {
    setState(() {
      msg.originalText ??= msg.text;
      // Determine target language based on whether text currently contains Tamil characters
      final hasTamil = msg.text.codeUnits.any((c) => c >= 0x0B80 && c <= 0x0BFF);
      final targetLang = hasTamil ? HoroscopeLanguage.english : HoroscopeLanguage.tamil;

      msg.text = AiHoroscopeService.translateMessage(msg.originalText!, targetLang);
      msg.isTranslated = !msg.isTranslated;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedLanguage == HoroscopeLanguage.tamil
              ? 'ஆலோசனை நகலெடுக்கப்பட்டது (Copied)'
              : 'Astrology advice copied to clipboard',
          style: GoogleFonts.outfit(color: AppColors.lightGold),
        ),
        backgroundColor: AppColors.cardSurfaceLight,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderGold, width: 1.2),
        ),
        title: Text(
          _selectedLanguage == HoroscopeLanguage.tamil
              ? 'உரையாடலை அழிக்கவா?'
              : 'Clear Conversation?',
          style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _selectedLanguage == HoroscopeLanguage.tamil
              ? 'தற்போதைய அனைத்து ஆலோசனைகளும் அழிக்கப்பட்டு புதிய ஆலோசனை தொடங்கும்.'
              : 'All current consultation messages will be cleared and reset.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _selectedLanguage == HoroscopeLanguage.tamil ? 'ரத்து' : 'Cancel',
              style: GoogleFonts.outfit(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _resetWelcomeMessage();
              });
            },
            child: Text(
              _selectedLanguage == HoroscopeLanguage.tamil ? 'ஆம், அழி' : 'Clear',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = _selectedLanguage == HoroscopeLanguage.tamil;
    final quickPrompts = AiHoroscopeService.getQuickPrompts(_selectedLanguage);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        elevation: 2,
        titleSpacing: 0,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isTamil ? 'AI ஜோதிட உதவியாளர்' : 'AI Horoscope Assistant',
                    style: GoogleFonts.cinzel(
                      color: AppColors.lightGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isTamil
                        ? 'வேத ஜோதிட வழிகாட்டுதல் (Vedic Advice)'
                        : 'Vedic Astrology Advice & Guidance',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // LANGUAGE TOGGLE SWITCHER: English ⇄ தமிழ்
          _buildLanguageToggle(),
          const SizedBox(width: 4),
          // Clear conversation action
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold, size: 22),
            tooltip: isTamil ? 'புதிய ஆலோசனை / அழி' : 'Reset Consultation',
            onPressed: _confirmClearChat,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg, isTamil);
                  },
                ),
              ),

              // Generating indicator
              if (_isGenerating)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isTamil
                            ? 'AI குரு உங்கள் கிரக நிலைகளை கணிக்கிறார்...'
                            : 'AI Guru is analyzing cosmic birth charts...',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Quick Prompts Horizontal Scroll
              _buildQuickPromptsBar(quickPrompts, isTamil),

              // Input Bar
              _buildInputBar(isTamil),
            ],
          ),
        ),
      ),
    );
  }

  /// Language Switcher Pill [ English | தமிழ் ]
  Widget _buildLanguageToggle() {
    final isTamil = _selectedLanguage == HoroscopeLanguage.tamil;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.18),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // English button
          GestureDetector(
            onTap: () => _toggleLanguage(HoroscopeLanguage.english),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: !isTamil ? AppColors.primaryGold : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'English',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: !isTamil ? FontWeight.bold : FontWeight.w500,
                  color: !isTamil ? Colors.black : Colors.white70,
                ),
              ),
            ),
          ),
          // Tamil button
          GestureDetector(
            onTap: () => _toggleLanguage(HoroscopeLanguage.tamil),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isTamil ? AppColors.primaryGold : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'தமிழ்',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: isTamil ? FontWeight.bold : FontWeight.w500,
                  color: isTamil ? Colors.black : Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Message Bubble with Translate and Copy tools
  Widget _buildMessageBubble(AiHoroscopeMessageItem msg, bool isCurrentTamil) {
    final isAstrologer = msg.isAstrologer;
    final hasTamil = msg.text.codeUnits.any((c) => c >= 0x0B80 && c <= 0x0BFF);

    return Align(
      alignment: isAstrologer ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAstrologer
              ? AppColors.cardSurface
              : AppColors.primaryGold.withValues(alpha: 0.22),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isAstrologer ? 4 : 18),
            bottomRight: Radius.circular(isAstrologer ? 18 : 4),
          ),
          border: Border.all(
            color: isAstrologer
                ? AppColors.borderGold.withValues(alpha: 0.4)
                : AppColors.lightGold,
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Sender Name & Icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAstrologer ? Icons.smart_toy_rounded : Icons.person_rounded,
                  size: 15,
                  color: AppColors.lightGold,
                ),
                const SizedBox(width: 6),
                Text(
                  msg.senderName,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content text
            SelectableText(
              msg.text,
              style: GoogleFonts.outfit(
                fontSize: 13.8,
                color: Colors.white,
                height: 1.48,
              ),
            ),

            const SizedBox(height: 10),

            // Action row for Astrologer responses: Translate & Copy
            if (isAstrologer)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Translate action button
                  InkWell(
                    onTap: () => _translateMessage(msg),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.translate, size: 12, color: AppColors.lightGold),
                          const SizedBox(width: 4),
                          Text(
                            hasTamil ? 'English Advice' : 'தமிழ் விளக்கம்',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Copy advice button
                  InkWell(
                    onTap: () => _copyToClipboard(msg.text),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded, size: 12, color: AppColors.lightGold),
                          const SizedBox(width: 4),
                          Text(
                            hasTamil ? 'நகலெடு' : 'Copy',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              color: AppColors.lightGold,
                            ),
                          ),
                        ],
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

  /// Quick Prompts Horizontal Chip List
  Widget _buildQuickPromptsBar(List<Map<String, String>> prompts, bool isTamil) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = prompts[index];
          return ActionChip(
            backgroundColor: AppColors.cardSurfaceLight,
            side: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            label: Text(
              item['title']!,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.lightGold,
              ),
            ),
            onPressed: () {
              _sendAiPrompt(customText: item['prompt']);
            },
          );
        },
      ),
    );
  }

  /// Input Bar
  Widget _buildInputBar(bool isTamil) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        border: Border(
          top: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: isTamil
                      ? 'AI ஜோதிட ஆலோசனையைக் கேட்கவும்... (தமிழ் / English)'
                      : 'Ask AI Horoscope Prediction... (English or Tamil)',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12.5),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendAiPrompt(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              onPressed: () => _sendAiPrompt(),
            ),
          ),
        ],
      ),
    );
  }
}
