import 'package:cloud_firestore/cloud_firestore.dart';

class Draw {
  final String id;
  final String itemId;
  final int ticketCount;
  final String status; // e.g., 'pending', 'active', 'completed'
  final DateTime? endTime;
  final String? winnerId;
  final String? winnerEmail;

  Draw({
    required this.id,
    required this.itemId,
    required this.ticketCount,
    required this.status,
    this.endTime,
    this.winnerId,
    this.winnerEmail,
  });

  factory Draw.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Draw(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      ticketCount: data['ticketCount'] ?? 0,
      status: data['status'] ?? 'pending',
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      winnerId: data['winnerId'],
      winnerEmail: data['winnerEmail'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'ticketCount': ticketCount,
      'status': status,
      'endTime': endTime,
      'winnerId': winnerId,
      'winnerEmail': winnerEmail,
    };
  }
}
