import 'dart:async';
import '../models/consultation_model.dart';
import '../models/astrologer_model.dart';

class CallingService {
  static ConsultationModel? _activeConsultation;

  static ConsultationModel? get activeConsultation => _activeConsultation;

  /// Start or Queue Consultation
  static Future<ConsultationModel> initiateConsultation({
    required AstrologerModel astrologer,
    required String type, // Chat, Voice, Video
    required String userName,
    required String userDob,
    required String userTimeOfBirth,
    required String userPlaceOfBirth,
    required String userZodiac,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final isBusy = astrologer.status == 'busy';
    final status = isBusy ? 'queued' : 'analysis_mode';

    _activeConsultation = ConsultationModel(
      id: 'cns_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_active',
      userName: userName,
      userDob: userDob,
      userTimeOfBirth: userTimeOfBirth,
      userPlaceOfBirth: userPlaceOfBirth,
      userZodiac: userZodiac,
      astrologerId: astrologer.id,
      astrologerName: astrologer.name,
      type: type,
      status: status,
      queuePosition: isBusy ? 2 : 1,
      estimatedWaitMinutes: isBusy ? 5 : 3,
      createdAt: DateTime.now(),
      durationMinutes: 30,
      totalAmount: astrologer.consultationFee * 10,
      isAnalysisComplete: false,
    );

    return _activeConsultation!;
  }

  /// Astrologer clicks Analysis Complete
  static void markAnalysisComplete() {
    if (_activeConsultation != null) {
      _activeConsultation = ConsultationModel.fromMap({
        ..._activeConsultation!.toMap(),
        'status': 'active',
        'isAnalysisComplete': true,
      });
    }
  }

  /// End Consultation
  static void endConsultation() {
    if (_activeConsultation != null) {
      _activeConsultation = ConsultationModel.fromMap({
        ..._activeConsultation!.toMap(),
        'status': 'completed',
      });
    }
  }
}
