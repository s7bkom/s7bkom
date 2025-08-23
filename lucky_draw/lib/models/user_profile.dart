import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final List<String> purchasedTickets;
  final List<String> wonDraws;
  final String? fcmToken;

  UserProfile({
    required this.id,
    required this.email,
    this.purchasedTickets = const [],
    this.wonDraws = const [],
    this.fcmToken,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      purchasedTickets: List<String>.from(data['purchasedTickets'] ?? []),
      wonDraws: List<String>.from(data['wonDraws'] ?? []),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'purchasedTickets': purchasedTickets,
      'wonDraws': wonDraws,
      'fcmToken': fcmToken,
    };
  }
}
