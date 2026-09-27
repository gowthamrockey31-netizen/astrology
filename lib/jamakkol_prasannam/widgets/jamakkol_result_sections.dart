import 'package:flutter/material.dart';
import '../models/jamakkol_models.dart';

/// Interactive result sections including Question Input, Interpretation Verdict, Combinations, Aspects, and Next 1-Hour Analysis
class JamakkolResultSectionsWidget extends StatefulWidget {
  final JamakkolChartState state;
  final bool isTamil;
  final void Function(String question, JamakkolQuestionCategory category)? onQuestionChanged;

  const JamakkolResultSectionsWidget({
    super.key,
    required this.state,
    this.isTamil = true,
    this.onQuestionChanged,
  });

  @override
  State<JamakkolResultSectionsWidget> createState() => _JamakkolResultSectionsWidgetState();
}

class _JamakkolResultSectionsWidgetState extends State<JamakkolResultSectionsWidget> {
  late TextEditingController _questionController;
  late JamakkolQuestionCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.state.question);
    _selectedCategory = widget.state.questionCategory;
  }

  @override
  void didUpdateWidget(covariant JamakkolResultSectionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.question != widget.state.question &&
        _questionController.text != widget.state.question) {
      _questionController.text = widget.state.question;
    }
    if (oldWidget.state.questionCategory != widget.state.questionCategory) {
      _selectedCategory = widget.state.questionCategory;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _triggerUpdate() {
    widget.onQuestionChanged?.call(_questionController.text, _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Question Input Section
        _buildQuestionInputCard(),
        const SizedBox(height: 14),

        // 2. Comprehensive Interpretation Verdict Card
        _buildVerdictCard(),
        const SizedBox(height: 14),

        // 3. Astrological Combinations & Yogas
        _buildCombinationsCard(),
        const SizedBox(height: 14),

        // 4. Planetary Aspects
        _buildAspectsCard(),
        const SizedBox(height: 14),

        // 5. Next 1-Hour Time Analysis
        _buildNextHourAnalysisCard(),
        const SizedBox(height: 14),

        // 6. Practical Guidance & Remedies
        _buildRemedyCard(),
      ],
    );
  }

  /// Question input and category selection
  Widget _buildQuestionInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Text(
                widget.isTamil ? 'உங்கள் கேள்வியை உள்ளிடுங்கள்' : 'Enter Your Question',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Text Field
          TextField(
            controller: _questionController,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: widget.isTamil
                  ? 'எ.கா: "இந்த வேலை எனக்கு கிடைக்குமா?", "வியாபாரம் தொடங்கலாமா?"'
                  : 'e.g. "Will I get this job?", "Is it a good time for business?"',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onSubmitted: (_) => _triggerUpdate(),
          ),
          const SizedBox(height: 10),

          // Category Chips
          Text(
            widget.isTamil ? 'கேள்வி பிரிவு (Category):' : 'Question Category:',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: JamakkolQuestionCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      _getCategoryShortName(cat),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF1E293B),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                        _triggerUpdate();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Verdict card with confidence score and breakdown
  Widget _buildVerdictCard() {
    final interp = widget.state.interpretation;
    final isFavorable = interp.isOverallFavorable;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFavorable
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [const Color(0xFF7F1D1D), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with score badge
          Row(
            children: [
              Icon(
                isFavorable ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isFavorable ? const Color(0xFF34D399) : const Color(0xFFF87171),
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.isTamil ? interp.verdictTitleTa : interp.verdictTitleEn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isFavorable ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${interp.confidenceScore}% அனுகூலம்',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Verdict Summary
          Text(
            widget.isTamil ? interp.verdictSummaryTa : interp.verdictSummaryEn,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),

          // Question Specific Analysis
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_alt_rounded, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.isTamil ? interp.questionCategoryLabelTa : interp.questionCategoryLabelEn,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isTamil ? interp.questionAnalysisTa : interp.questionAnalysisEn,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Three Pillars Quick Breakdown
          _buildPillarBullet(widget.isTamil ? 'உதய பலன்' : 'Udayam Analysis', widget.isTamil ? interp.udayamAnalysisTa : interp.udayamAnalysisEn, const Color(0xFF60A5FA)),
          const SizedBox(height: 4),
          _buildPillarBullet(widget.isTamil ? 'ஆருட பலன்' : 'Arudam Analysis', widget.isTamil ? interp.arudamAnalysisTa : interp.arudamAnalysisEn, const Color(0xFF34D399)),
          const SizedBox(height: 4),
          _buildPillarBullet(widget.isTamil ? 'கவிப்பு பலன்' : 'Kavippu Analysis', widget.isTamil ? interp.kavippuAnalysisTa : interp.kavippuAnalysisEn, const Color(0xFFF87171)),
        ],
      ),
    );
  }

  Widget _buildPillarBullet(String title, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 5, right: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, height: 1.3),
              children: [
                TextSpan(text: '$title: ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                TextSpan(text: desc, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Astrological combinations card
  Widget _buildCombinationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.isTamil ? 'முக்கிய யோகங்கள் & அமைப்புகள்' : 'Key Planetary Combinations',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.state.combinations.isEmpty)
            Text(
              widget.isTamil ? 'குறிப்பிட்ட விசேஷ யோகங்கள் இல்லை' : 'No prominent combinations present',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            ...widget.state.combinations.map((comb) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: comb.isFavorable ? const Color(0xFF10B981).withValues(alpha: 0.5) : const Color(0xFFEF4444).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      comb.isFavorable ? Icons.thumb_up_rounded : Icons.warning_amber_rounded,
                      color: comb.isFavorable ? const Color(0xFF34D399) : const Color(0xFFF87171),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isTamil ? comb.titleTa : comb.titleEn,
                            style: TextStyle(
                              color: comb.isFavorable ? const Color(0xFF34D399) : const Color(0xFFF87171),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isTamil ? comb.descriptionTa : comb.descriptionEn,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Planetary aspects card
  Widget _buildAspectsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.isTamil ? 'கிரக பார்வைகள் (Aspects)' : 'Planetary Aspects',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.state.aspects.isEmpty)
            Text(
              widget.isTamil ? 'முக்கிய பார்வைகள் பதிவாகவில்லை' : 'No direct aspects found',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            ...widget.state.aspects.take(6).map((asp) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: asp.isBenefic ? const Color(0xFF059669).withValues(alpha: 0.3) : const Color(0xFFDC2626).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.isTamil ? asp.aspectTypeTa : asp.aspectTypeEn,
                        style: TextStyle(
                          color: asp.isBenefic ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.isTamil ? asp.descriptionTa : asp.descriptionEn,
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Next 1-Hour Time Analysis Card
  Widget _buildNextHourAnalysisCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.isTamil ? 'அடுத்த 1 மணி நேர பலன் (Next 1 Hour)' : 'Next 1-Hour Time Breakdown',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.isTamil
                ? 'ஒவ்வொரு 5 நிமிடத்திற்கும் மாறும் ஆருட பலன் (30° சுழற்சி):'
                : 'Arudam shifts every 5 minutes (30° traversal):',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 10),

          // Timeline Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
              dataRowMinHeight: 34,
              dataRowMaxHeight: 40,
              columnSpacing: 14,
              horizontalMargin: 8,
              columns: [
                DataColumn(label: Text(widget.isTamil ? 'நேரம்' : 'Time', style: _tHeaderStyle)),
                DataColumn(label: Text(widget.isTamil ? 'ஆருடம்' : 'Arudam', style: _tHeaderStyle)),
                DataColumn(label: Text(widget.isTamil ? 'நிலை' : 'Status', style: _tHeaderStyle)),
                DataColumn(label: Text(widget.isTamil ? 'பேச்சு' : 'Negotiate', style: _tHeaderStyle)),
                DataColumn(label: Text(widget.isTamil ? 'சுபகாரியம்' : 'Muhurtham', style: _tHeaderStyle)),
                DataColumn(label: Text(widget.isTamil ? 'பணம்' : 'Money', style: _tHeaderStyle)),
              ],
              rows: widget.state.nextHourSlots.map((slot) {
                return DataRow(
                  color: slot.isFavorable ? WidgetStateProperty.all(const Color(0xFF10B981).withValues(alpha: 0.08)) : null,
                  cells: [
                    DataCell(Text(
                      '${_formatShortTime(slot.startTime)}-${_formatShortTime(slot.endTime)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    )),
                    DataCell(Text(
                      widget.isTamil ? slot.arudamRasiTa : slot.arudamRasiEn,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                    )),
                    DataCell(Text(
                      slot.isFavorable ? '✅ சாதகம்' : '❌ சுமாரானது',
                      style: TextStyle(
                        color: slot.isFavorable ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )),
                    DataCell(Text(slot.negotiationFavorable ? '✅' : '❌', style: const TextStyle(fontSize: 12))),
                    DataCell(Text(slot.muhurthamFavorable ? '✅' : '❌', style: const TextStyle(fontSize: 12))),
                    DataCell(Text(slot.moneyFavorable ? '✅' : '❌', style: const TextStyle(fontSize: 12))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Practical Guidance and Remedy Card
  Widget _buildRemedyCard() {
    final interp = widget.state.interpretation;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.isTamil ? 'வழிகாட்டல் & ஜோதிடப் பரிகாரம்' : 'Guidance & Remedies',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Positive factors
          if (interp.positiveIndicatorsTa.isNotEmpty) ...[
            Text(
              widget.isTamil ? 'சாதகமான அம்சங்கள்:' : 'Positive Factors:',
              style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ...interp.positiveIndicatorsTa.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✔ ', style: TextStyle(color: Color(0xFF34D399), fontSize: 12)),
                      Expanded(child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 11.5))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],

          // Warning factors
          if (interp.warningIndicatorsTa.isNotEmpty) ...[
            Text(
              widget.isTamil ? 'கவனிக்க வேண்டியவை:' : 'Points of Caution:',
              style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ...interp.warningIndicatorsTa.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠ ', style: TextStyle(color: Color(0xFFF87171), fontSize: 12)),
                      Expanded(child: Text(w, style: const TextStyle(color: Colors.white70, fontSize: 11.5))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],

          // Recommended remedy
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.temple_hindu_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isTamil ? interp.practicalRemedyTa : interp.practicalRemedyEn,
                    style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryShortName(JamakkolQuestionCategory cat) {
    switch (cat) {
      case JamakkolQuestionCategory.job:
        return widget.isTamil ? 'உத்தியோகம்' : 'Job';
      case JamakkolQuestionCategory.business:
        return widget.isTamil ? 'வியாபாரம்' : 'Business';
      case JamakkolQuestionCategory.marriage:
        return widget.isTamil ? 'திருமணம்' : 'Marriage';
      case JamakkolQuestionCategory.money:
        return widget.isTamil ? 'தனம்' : 'Money';
      case JamakkolQuestionCategory.loan:
        return widget.isTamil ? 'கடன்' : 'Loan';
      case JamakkolQuestionCategory.property:
        return widget.isTamil ? 'சொத்து' : 'Property';
      case JamakkolQuestionCategory.travel:
        return widget.isTamil ? 'பயணம்' : 'Travel';
      case JamakkolQuestionCategory.legal:
        return widget.isTamil ? 'வழக்கு' : 'Legal';
      case JamakkolQuestionCategory.lostItem:
        return widget.isTamil ? 'பொருள் மீட்பு' : 'Lost Item';
      case JamakkolQuestionCategory.relationship:
        return widget.isTamil ? 'குடும்பம்' : 'Family';
      case JamakkolQuestionCategory.health:
        return widget.isTamil ? 'ஆரோக்கியம்' : 'Health';
      case JamakkolQuestionCategory.competition:
        return widget.isTamil ? 'போட்டி' : 'Exams';
      case JamakkolQuestionCategory.general:
        return widget.isTamil ? 'பொது' : 'General';
    }
  }

  String _formatShortTime(DateTime dt) {
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hr:$min';
  }

  static const _tHeaderStyle = TextStyle(
    color: Color(0xFFFFD700),
    fontWeight: FontWeight.bold,
    fontSize: 11,
  );
}
