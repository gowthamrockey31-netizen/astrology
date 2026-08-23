class ConsultationModel {
  final String id;
  final String userId;
  final String userName;
  final String userDob;
  final String userTimeOfBirth;
  final String userPlaceOfBirth;
  final String userZodiac;
  final String astrologerId;
  final String astrologerName;
  final String type; // Chat, Voice, Video
  final String status; // queued, analysis, active, completed, cancelled
  final int queuePosition;
  final int estimatedWaitMinutes;
  final DateTime createdAt;
  final int durationMinutes;
  final double totalAmount;
  final bool isAnalysisComplete;
  final String? rating;
  final String? reviewComment;

  ConsultationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userDob,
    required this.userTimeOfBirth,
    required this.userPlaceOfBirth,
    required this.userZodiac,
    required this.astrologerId,
    required this.astrologerName,
    required this.type,
    required this.status,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
    required this.createdAt,
    this.durationMinutes = 30,
    required this.totalAmount,
    this.isAnalysisComplete = false,
    this.rating,
    this.reviewComment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userDob': userDob,
      'userTimeOfBirth': userTimeOfBirth,
      'userPlaceOfBirth': userPlaceOfBirth,
      'userZodiac': userZodiac,
      'astrologerId': astrologerId,
      'astrologerName': astrologerName,
      'type': type,
      'status': status,
      'queuePosition': queuePosition,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'createdAt': createdAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'totalAmount': totalAmount,
      'isAnalysisComplete': isAnalysisComplete,
      'rating': rating,
      'reviewComment': reviewComment,
    };
  }

  factory ConsultationModel.fromMap(Map<String, dynamic> map) {
    return ConsultationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'User',
      userDob: map['userDob'] ?? '',
      userTimeOfBirth: map['userTimeOfBirth'] ?? '',
      userPlaceOfBirth: map['userPlaceOfBirth'] ?? '',
      userZodiac: map['userZodiac'] ?? 'Aries',
      astrologerId: map['astrologerId'] ?? '',
      astrologerName: map['astrologerName'] ?? '',
      type: map['type'] ?? 'Chat',
      status: map['status'] ?? 'active',
      queuePosition: map['queuePosition'] ?? 1,
      estimatedWaitMinutes: map['estimatedWaitMinutes'] ?? 3,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      durationMinutes: map['durationMinutes'] ?? 30,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 300.0,
      isAnalysisComplete: map['isAnalysisComplete'] ?? false,
      rating: map['rating'],
      reviewComment: map['reviewComment'],
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isAstrologer;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isAstrologer,
  });
}
