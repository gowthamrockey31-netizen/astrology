import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/astrologer_model.dart';
import '../../models/consultation_model.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/south_indian_jathagam_widget.dart';

class ConsultationScreen extends StatefulWidget {
  final AstrologerModel astrologer;
  final String consultationType; // Voice, Video, Chat
  final VoidCallback onEndCall;

  const ConsultationScreen({
    super.key,
    required this.astrologer,
    required this.consultationType,
    required this.onEndCall,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool _isAnalysisMode = true;
  int _analysisSeconds = 180; // 3 minutes analysis timer
  int _callSecondsLeft = 1800; // 30 minutes call countdown timer
  late Timer _analysisTimer;
  late Timer _callTimer;

  bool _isMuted = false;
  bool _isVideoOff = false;

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg_1',
      senderId: 'astrologer',
      senderName: 'Astrologer',
      text: 'Om Namah Shivaya! I am analyzing your birth chart (Rasi & Navamsha) with Nakshatra Pathasaram.',
      timestamp: DateTime.now(),
      isAstrologer: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAnalysisTimer();
  }

  void _startAnalysisTimer() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_analysisSeconds <= 1) {
        _analysisTimer.cancel();
        _completeAnalysis();
      } else {
        setState(() {
          _analysisSeconds--;
        });
      }
    });
  }

  void _completeAnalysis() {
    if (_analysisTimer.isActive) _analysisTimer.cancel();
    setState(() {
      _isAnalysisMode = false;
    });
    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callSecondsLeft <= 1) {
        _callTimer.cancel();
        _showExtensionModal();
      } else {
        setState(() {
          _callSecondsLeft--;
        });
      }
    });
  }

  void _showJathagamModal() {
    final user = AuthService.currentUser;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: AppColors.backgroundDeep,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Call Birth Chart (ராசி & நவாம்சம்)',
                      style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SouthIndianJathagamWidget(user: user, isCallOverlay: true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExtensionModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        title: Text(
          'Extend Consultation?',
          style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Your 30-minute session has ended. Would you like to extend by 10 minutes for ₹${(widget.astrologer.consultationFee * 10).toStringAsFixed(0)}?',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onEndCall();
            },
            child: const Text('End Call', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            onPressed: () async {
              Navigator.of(context).pop();
              final res = await PaymentService.processPayment(
                amount: widget.astrologer.consultationFee * 10,
                paymentMethod: 'Wallet',
                title: 'Consultation 10 Min Extension',
              );
              if (res.isSuccess) {
                setState(() {
                  _callSecondsLeft += 600;
                });
                _startCallTimer();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                widget.onEndCall();
              }
            },
            child: Text('Extend (Wallet)', style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.currentUser;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user',
          senderName: user?.name ?? 'You',
          text: text,
          timestamp: DateTime.now(),
          isAstrologer: false,
        ),
      );
      _chatController.clear();
    });

    // Simulated Astrologer AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
              senderId: 'astrologer',
              senderName: widget.astrologer.name,
              text: 'Looking at your Rasi and Navamsha kattam, performing a Rahu Ketu Shanti pooja will yield great peace and success.',
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
    if (_analysisTimer.isActive) _analysisTimer.cancel();
    if (_callTimer.isActive) _callTimer.cancel();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _callSecondsLeft ~/ 60;
    final seconds = _callSecondsLeft % 60;
    final timeFormatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.astrologer.name,
              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
            Text(
              _isAnalysisMode ? 'Horoscope Analysis Mode' : 'Active ${widget.consultationType} Consultation',
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on_rounded, color: AppColors.lightGold),
            tooltip: 'View Birth Chart (ராசி & நவாம்சம்)',
            onPressed: _showJathagamModal,
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGold),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, size: 14, color: AppColors.lightGold),
                const SizedBox(width: 4),
                Text(
                  timeFormatted,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Body based on Consultation Type
          if (_isAnalysisMode)
            _buildAnalysisModeView()
          else if (widget.consultationType == 'Chat')
            _buildChatView()
          else if (widget.consultationType == 'Voice')
            _buildVoiceCallView()
          else
            _buildVideoCallView(),

          // End Call & View Chart Floating Action Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryGold.withOpacity(0.25),
                  child: IconButton(
                    icon: const Icon(Icons.pie_chart_rounded, color: AppColors.lightGold),
                    tooltip: 'Birth Chart (ராசி & நவாம்சம்)',
                    onPressed: _showJathagamModal,
                  ),
                ),
                if (widget.consultationType != 'Chat' && !_isAnalysisMode)
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _isMuted ? Colors.redAccent : AppColors.cardSurface,
                    child: IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                    ),
                  ),
                FloatingActionButton.extended(
                  backgroundColor: Colors.redAccent,
                  onPressed: widget.onEndCall,
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  label: Text('End Session', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                if (widget.consultationType == 'Video' && !_isAnalysisMode)
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _isVideoOff ? Colors.redAccent : AppColors.cardSurface,
                    child: IconButton(
                      icon: Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                      onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisModeView() {
    final aMinutes = _analysisSeconds ~/ 60;
    final aSeconds = _analysisSeconds % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardSurface,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 60),
            ),
            const SizedBox(height: 20),
            Text(
              'The astrologer requires approximately 3–5 minutes to analyze your horoscope.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Analysis Time Remaining: ${aMinutes.toString().padLeft(2, '0')}:${aSeconds.toString().padLeft(2, '0')}',
              style: GoogleFonts.cinzel(fontSize: 18, color: AppColors.lightGold, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, color: AppColors.backgroundDeep),
              label: Text('Astrologer: Analysis Completed', style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold)),
              onPressed: _completeAnalysis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment: msg.isAstrologer ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg.isAstrologer ? AppColors.cardSurface : AppColors.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: msg.isAstrologer ? Colors.white12 : AppColors.lightGold),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.senderName,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                      ),
                      const SizedBox(height: 4),
                      Text(msg.text, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
          color: AppColors.backgroundMid,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask your astrological question...',
                    hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.lightGold),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceCallView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.astrologer.photoUrl),
          ),
          const SizedBox(height: 20),
          Text(widget.astrologer.name, style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Live Cosmic Voice Audio Connected', style: GoogleFonts.outfit(color: AppColors.lightGold)),
        ],
      ),
    );
  }

  Widget _buildVideoCallView() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 50, backgroundImage: NetworkImage(widget.astrologer.photoUrl)),
                const SizedBox(height: 12),
                Text('Video Stream Active with ${widget.astrologer.name}', style: GoogleFonts.outfit(color: Colors.white70)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 110,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGold, width: 1.5),
            ),
            child: Center(
              child: Text('Your Feed', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
            ),
          ),
        ),
      ],
    );
  }
}
