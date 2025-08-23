import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String drawId;
  final String userId;
  final String ticketNumber;
  final DateTime purchaseDate;

  Ticket({
    required this.id,
    required this.drawId,
    required this.userId,
    required this.ticketNumber,
    required this.purchaseDate,
  });

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      drawId: data['drawId'] ?? '',
      userId: data['userId'] ?? '',
      ticketNumber: data['ticketNumber'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'drawId': drawId,
      'userId': userId,
      'ticketNumber': ticketNumber,
      'purchaseDate': purchaseDate,
    };
  }
}
